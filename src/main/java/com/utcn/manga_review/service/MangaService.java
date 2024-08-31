package com.utcn.manga_review.service;

import com.utcn.manga_review.entity.Manga;
import com.utcn.manga_review.entity.MangaStatus;
import com.utcn.manga_review.entity.Review;
import com.utcn.manga_review.repository.MangaRepository;
import com.utcn.manga_review.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MangaService {
    private final MangaRepository mangaRepository;
    private final ReviewRepository reviewRepository;

    public List<Manga> retrieveMangas() {
        return (List<Manga>) this.mangaRepository.findAll();
    }

    public Manga insertManga(Manga manga) {
        return this.mangaRepository.save(manga);
    }

    public Manga updateManga(Long id, Manga updatedManga) {
        Optional<Manga> optionalManga = this.mangaRepository.findById(id);
        if (optionalManga.isPresent()) {
            Manga manga = optionalManga.get();
            manga.setTitle(updatedManga.getTitle());
            manga.setAuthor(updatedManga.getAuthor());
            manga.setTags(updatedManga.getTags());
            manga.setChapters(updatedManga.getChapters());
            manga.setReleaseDate(updatedManga.getReleaseDate());
            manga.setStatus(updatedManga.getStatus());
            manga.setScore(updatedManga.getScore());
            manga.setReviews(updatedManga.getReviews());
            return this.mangaRepository.save(manga);
        } else {
            throw new RuntimeException("Manga not found");
        }
    }

    public void deleteMangaById(Long id) {
        if (mangaRepository.findById(id).isEmpty()) {
            throw new RuntimeException("Manga not found");
        } else {
            this.mangaRepository.deleteById(id);
        }
    }

    public Manga getMangaById(Long id) {
        return mangaRepository.findById(id).orElseThrow(() -> new RuntimeException("Manga not found"));
    }

    public Manga updateMangaScore(Long mangaId) {
        Manga manga = getMangaById(mangaId);
        List<Review> reviews = reviewRepository.findByMangaId(mangaId);
        double averageScore = reviews.stream()
                .mapToDouble(Review::getScore)
                .average()
                .orElse(0.0);
        manga.setScore(averageScore);
        return mangaRepository.save(manga);
    }

    public Manga updateReviewCount(Long mangaId) {
        // Retrieve the manga by ID
        Manga manga = getMangaById(mangaId);

        // Count the number of reviews for this manga
        long reviewCount = reviewRepository.countByMangaId(mangaId);

        // Update the manga's reviews field
        manga.setReviews(reviewCount);

        // Save the updated manga back to the repository
        return mangaRepository.save(manga);
    }

    public List<Manga> sortMangasByTags(List<String> tags) {
        List<Manga> mangas = sortMangasByScore();
        return mangas.stream()
                .filter(manga -> containsAllTags(manga.getTags(), tags))
                .sorted(Comparator.comparingInt((Manga manga) ->
                        countMatchingTags(manga.getTags(), tags)).reversed())
                .collect(Collectors.toList());
    }

    private boolean containsAllTags(String mangaTags, List<String> tags) {
        List<String> mangaTagList = List.of(mangaTags.split(" "));
        return tags.stream().allMatch(mangaTagList::contains);
    }

    private int countMatchingTags(String mangaTags, List<String> tags) {
        List<String> mangaTagList = List.of(mangaTags.split(" "));
        return (int) tags.stream()
                .filter(mangaTagList::contains)
                .count();
    }

    public List<Manga> sortMangasByScore() {
        return mangaRepository.findAll()
                .stream()
                .sorted(Comparator.comparingDouble(Manga::getScore).reversed())
                .collect(Collectors.toList());
    }

    public List<Manga> findMangasByStatus(MangaStatus status) {
        return mangaRepository.findByStatus(status)
                .stream()
                .sorted(Comparator.comparingDouble(Manga::getScore).reversed())
                .collect(Collectors.toList());
    }

    public Manga findMangaByTitle(String title) {
        return mangaRepository.findByTitle(title);
    }

    public List<String> getAllUniqueTags() {
        // Retrieve all Manga entities from the repository
        List<Manga> mangas = retrieveMangas();

        // Create a set to hold unique tags
        Set<String> uniqueTags = new HashSet<>();

        // Iterate over each Manga and extract tags
        for (Manga manga : mangas) {
            // Split tags by space and add them to the set
            String[] tags = manga.getTags().split(" ");
            for (String tag : tags) {
                uniqueTags.add(tag);
            }
        }

        // Convert the set of unique tags to a list and return it
        return uniqueTags.stream().collect(Collectors.toList());
    }

    public void updateAllMangaScores() {
        List<Manga> allMangas = retrieveMangas();
        for (Manga manga : allMangas) {
            updateMangaScore(manga.getId());
        }
    }

    public void updateAllMangaReviewCounts() {
        List<Manga> allMangas = retrieveMangas();
        for (Manga manga : allMangas) {
            updateReviewCount(manga.getId());
        }
    }

}

