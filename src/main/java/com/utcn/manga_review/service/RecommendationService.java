package com.utcn.manga_review.service;

import com.utcn.manga_review.entity.Manga;
import com.utcn.manga_review.entity.Recommendation;
import com.utcn.manga_review.entity.Review;
import com.utcn.manga_review.entity.User;
import com.utcn.manga_review.repository.MangaRepository;
import com.utcn.manga_review.repository.RecommendationRepository;
import com.utcn.manga_review.repository.ReviewRepository;
import com.utcn.manga_review.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RecommendationService {
    private final RecommendationRepository recommendationRepository;
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;
    private final MangaRepository mangaRepository;

    // Retrieve all Recommendation entries
    public List<Recommendation> retrieveRecommendations() {
        return (List<Recommendation>) this.recommendationRepository.findAll();
    }

    // Insert a new Recommendation entry
    public Recommendation insertRecommendation(Recommendation recommendation) {
        return this.recommendationRepository.save(recommendation);
    }

    // Update an existing Recommendation entry
    public Recommendation updateRecommendation(Long id, Recommendation updatedRecommendation) {
        Optional<Recommendation> optionalRecommendation = this.recommendationRepository.findById(id);
        if (optionalRecommendation.isPresent()) {
            Recommendation recommendation = optionalRecommendation.get();
            recommendation.setUser(updatedRecommendation.getUser());
            recommendation.setManga(updatedRecommendation.getManga());
            recommendation.setReason(updatedRecommendation.getReason());
            return this.recommendationRepository.save(recommendation);
        } else {
            throw new RuntimeException("Recommendation not found");
        }
    }

    // Delete a Recommendation entry by ID
    public void deleteRecommendationById(Long id) {
        if (recommendationRepository.findById(id).isEmpty()) {
            throw new RuntimeException("Recommendation not found");
        } else {
            this.recommendationRepository.deleteById(id);
        }
    }

    // Find a Recommendation by ID
    public Recommendation getRecommendationById(Long id) {
        return recommendationRepository.findById(id).orElseThrow(() -> new RuntimeException("Recommendation not found"));
    }

    public List<Recommendation> getRecommendationsByUsername(String username) {
        // Fetch the user by username
        Optional<User> optionalUser = userRepository.findByUsername(username);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("User not found with username: " + username);
        }
        User user = optionalUser.get();

        // Fetch all recommendations for the found user
        return recommendationRepository.findByUserId(user.getId());
    }

    // Create and store a recommendation for a given user based on their most reviewed tag
    public Recommendation createRecommendation(Long userId) {
        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User user = optionalUser.get();
        List<Review> reviews = reviewRepository.findByUserId(userId);

        if (reviews.isEmpty()) {
            throw new RuntimeException("No reviews found for user with ID: " + userId);
        }

        // Analyze the tags to determine the most reviewed tag
        Map<String, Long> tagCounts = reviews.stream()
                .flatMap(review -> Arrays.stream(review.getManga().getTags().split(" "))) // Split by space
                .collect(Collectors.groupingBy(tag -> tag, Collectors.counting()));

        String mostReviewedTag = tagCounts.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElseThrow(() -> new RuntimeException("Could not determine the most reviewed tag"));

        // Find the manga with the highest score that contains the most reviewed tag and is not reviewed by the user
        List<Manga> mangasWithMostReviewedTag = mangaRepository.findByTagsContaining(mostReviewedTag);
        List<Recommendation> existingRecommendations = recommendationRepository.findByUserId(userId);

        Manga recommendedManga = mangasWithMostReviewedTag.stream()
                .filter(manga -> reviews.stream().noneMatch(review -> review.getManga().getId().equals(manga.getId())))
                .filter(manga -> existingRecommendations.stream().noneMatch(rec -> rec.getManga().getId().equals(manga.getId())))
                .max(Comparator.comparing(Manga::getScore))
                .orElseThrow(() -> new RuntimeException("No suitable manga found for recommendation"));

        // Create a new recommendation based on the most reviewed tag
        Recommendation recommendation = new Recommendation();
        recommendation.setUser(user);
        recommendation.setReason(String.format(
                "We recommend you check out *%s* by author *%s* because of your positive reviews in the genre *%s*.",
                recommendedManga.getTitle(), recommendedManga.getAuthor(), mostReviewedTag));
        recommendation.setManga(recommendedManga); // Ensure you set the manga reference if needed

        // Save the recommendation to the database
        return recommendationRepository.save(recommendation);
    }

    public Recommendation recommendRandomManga(Long userId) {
        Optional<User> optionalUser = userRepository.findById(userId);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("User not found");
        }
        User user = optionalUser.get();

        // Fetch all reviews by the user
        List<Manga> reviewedMangas = recommendationRepository.findByUserId(userId).stream()
                .map(Recommendation::getManga)
                .toList();

        List<Manga> allMangas = (List<Manga>) mangaRepository.findAll();

        // Filter out the reviewed mangas
        List<Manga> unreviewedMangas = allMangas.stream()
                .filter(manga -> reviewedMangas.stream().noneMatch(reviewedManga -> reviewedManga.getId().equals(manga.getId())))
                .toList();

        if (unreviewedMangas.isEmpty()) {
            throw new RuntimeException("No unreviewed mangas found for recommendation");
        }

        // Pick a random manga from the filtered list
        Manga randomManga = unreviewedMangas.get(new Random().nextInt(unreviewedMangas.size()));

        // Create a recommendation
        Recommendation recommendation = new Recommendation();
        recommendation.setUser(user);
        recommendation.setManga(randomManga);
        recommendation.setReason(String.format("We recommend you check out *%s* by author *%s*. Enjoy exploring new content!",
                randomManga.getTitle(), randomManga.getAuthor()));

        // Save the recommendation to the database
        return recommendationRepository.save(recommendation);
    }


}
