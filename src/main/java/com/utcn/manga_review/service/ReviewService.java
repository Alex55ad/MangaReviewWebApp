package com.utcn.manga_review.service;

import com.utcn.manga_review.entity.Review;
import com.utcn.manga_review.entity.User;
import com.utcn.manga_review.repository.ReviewRepository;
import com.utcn.manga_review.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviewRepository;
    private final UserRepository userRepository;

    public List<Review> getReviewsByUserId(Long userId) {
        return reviewRepository.findByUserId(userId);
    }

    public List<Review> retrieveReviews() {
        return (List<Review>) this.reviewRepository.findAll();
    }

    public Review insertReview(Review review) {
        return this.reviewRepository.save(review);
    }

    public Review updateReview(Long id, Review updatedReview) {
        Optional<Review> optionalReview = this.reviewRepository.findById(id);
        if (optionalReview.isPresent()) {
            Review review = optionalReview.get();
            review.setUser(updatedReview.getUser());
            review.setManga(updatedReview.getManga());
            review.setStatus(updatedReview.getStatus());
            review.setDate(updatedReview.getDate());
            review.setTitle(updatedReview.getTitle());
            review.setBody(updatedReview.getBody());
            review.setScore(updatedReview.getScore());
            review.setChapter(updatedReview.getChapter());
            return this.reviewRepository.save(review);
        } else {
            throw new RuntimeException("Review not found");
        }
    }

    public List<Review> getReviewsByUsername(String username) {
        // Find the user by username
        Optional<User> userOptional = userRepository.findByUsername(username);
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found with username: " + username);
        }

        // Retrieve the user's ID
        Long userId = userOptional.get().getId();

        // Retrieve all reviews for the user's ID
        List<Review> reviews = reviewRepository.findByUserId(userId);

        // Sort the reviews by score from highest to lowest
        reviews.sort(Comparator.comparing(Review::getScore).reversed());

        return reviews;
    }

    public void deleteReviewById(Long id) {
        if (reviewRepository.findById(id).isEmpty()) {
            throw new RuntimeException("Review not found");
        } else {
            this.reviewRepository.deleteById(id);
        }
    }

    public Review getReviewById(Long id) {
        return reviewRepository.findById(id).orElseThrow(() -> new RuntimeException("Review not found"));
    }

    public Optional<Review> getReviewByMangaIdAndUsername(Long mangaId, String username) {
        // Find the user by username
        Optional<User> userOptional = userRepository.findByUsername(username);
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found with username: " + username);
        }

        // Retrieve the user's ID
        Long userId = userOptional.get().getId();

        // Find the review by mangaId and userId
        return reviewRepository.findByMangaIdAndUserId(mangaId, userId);
    }

}
