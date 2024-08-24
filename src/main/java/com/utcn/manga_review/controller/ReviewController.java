package com.utcn.manga_review.controller;

import com.utcn.manga_review.entity.Review;
import com.utcn.manga_review.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RequestMapping("/reviews")
@RestController
@CrossOrigin
@RequiredArgsConstructor
public class ReviewController {
    private final ReviewService reviewService;

    // Retrieve all Review entries
    @GetMapping("/getAll")
    public List<Review> retrieveAllReviews() {
        return reviewService.retrieveReviews();
    }

    // Insert a new Review entry
    @PostMapping("/insert")
    public Review insertReview(@RequestBody Review review) {
        return reviewService.insertReview(review);
    }

    // Update an existing Review entry
    @PutMapping("/update")
    public ResponseEntity<Review> updateReview(@RequestParam Long id, @RequestBody Review updatedReview) {
        try {
            Review review = reviewService.updateReview(id, updatedReview);
            return ResponseEntity.ok(review);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete a Review entry by ID
    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteReviewById(@RequestParam Long id) {
        try {
            reviewService.deleteReviewById(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Find a Review by ID
    @GetMapping("/getById")
    public ResponseEntity<Review> getReviewById(@RequestParam Long id) {
        try {
            Review review = reviewService.getReviewById(id);
            return ResponseEntity.ok(review);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Retrieve all reviews for a user by userId
    @GetMapping("/getByUser")
    public ResponseEntity<List<Review>> getReviewsByUserId(@RequestParam Long userId) {
        List<Review> reviews = reviewService.getReviewsByUserId(userId);
        if (reviews.isEmpty()) {
            return ResponseEntity.noContent().build();
        } else {
            return ResponseEntity.ok(reviews);
        }
    }

    @GetMapping("/getByUsername")
    public ResponseEntity<List<Review>> getReviewsByUsername(@RequestParam String username) {
        try {
            List<Review> reviews = reviewService.getReviewsByUsername(username);
            return ResponseEntity.ok(reviews);
        } catch (RuntimeException e) {
            // Handle exceptions (e.g., user not found)
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/getByMangaIdAndUsername")
    public ResponseEntity<Review> getReviewByMangaIdAndUsername(@RequestParam Long mangaId, @RequestParam String username) {
        Optional<Review> reviewOptional = reviewService.getReviewByMangaIdAndUsername(mangaId, username);

        return reviewOptional
                .map(ResponseEntity::ok) // Return 200 OK with the review if found
                .orElseGet(() -> ResponseEntity.notFound().build()); // Return 404 Not Found if the review doesn't exist
    }

}
