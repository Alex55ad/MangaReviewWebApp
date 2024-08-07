package com.utcn.manga_review.service;

import com.utcn.manga_review.entity.Review;
import com.utcn.manga_review.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReviewService {
    private final ReviewRepository reviewRepository;

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
}
