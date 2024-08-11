package com.utcn.manga_review.controller;

import com.utcn.manga_review.entity.Recommendation;
import com.utcn.manga_review.service.RecommendationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequestMapping("/recommendations")
@RestController
@CrossOrigin
@RequiredArgsConstructor
public class RecommendationController {
    private final RecommendationService recommendationService;

    // Retrieve all Recommendation entries
    @GetMapping("/getAll")
    public List<Recommendation> retrieveAllRecommendations() {
        return recommendationService.retrieveRecommendations();
    }

    // Insert a new Recommendation entry
    @PostMapping("/insert")
    public Recommendation insertRecommendation(@RequestBody Recommendation recommendation) {
        return recommendationService.insertRecommendation(recommendation);
    }

    // Update an existing Recommendation entry
    @PutMapping("/update")
    public ResponseEntity<Recommendation> updateRecommendation(@RequestParam Long id, @RequestBody Recommendation updatedRecommendation) {
        try {
            Recommendation recommendation = recommendationService.updateRecommendation(id, updatedRecommendation);
            return ResponseEntity.ok(recommendation);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete a Recommendation entry by ID
    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteRecommendationById(@RequestParam Long id) {
        try {
            recommendationService.deleteRecommendationById(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Find a Recommendation by ID
    @GetMapping("/getById")
    public ResponseEntity<Recommendation> getRecommendationById(@RequestParam Long id) {
        try {
            Recommendation recommendation = recommendationService.getRecommendationById(id);
            return ResponseEntity.ok(recommendation);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/create")
    public ResponseEntity<Recommendation> createRecommendation(@RequestParam Long userId) {
        try {
            Recommendation recommendation = recommendationService.createRecommendation(userId);
            return ResponseEntity.ok(recommendation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null); // Return bad request if there's an issue
        }
    }

    @PostMapping("/recommendRandomManga")
    public ResponseEntity<Recommendation> recommendRandomManga(@RequestParam Long userId) {
        try {
            Recommendation recommendation = recommendationService.recommendRandomManga(userId);
            return ResponseEntity.ok(recommendation);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null); // You might want to customize the error handling
        }
    }

    @GetMapping("/getByUser")
    public ResponseEntity<List<Recommendation>> getRecommendationsByUsername(@RequestParam String username) {
        try {
            List<Recommendation> recommendations = recommendationService.getRecommendationsByUsername(username);
            return ResponseEntity.ok(recommendations);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

}
