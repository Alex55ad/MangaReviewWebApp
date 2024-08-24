package com.utcn.manga_review.controller;

import com.utcn.manga_review.entity.Manga;
import com.utcn.manga_review.entity.MangaStatus;
import com.utcn.manga_review.service.MangaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequestMapping("/mangas")
@RestController
@CrossOrigin
@RequiredArgsConstructor
public class MangaController {
    private final MangaService mangaService;

    // Retrieve all Manga entries
    @GetMapping("/getAll")
    public List<Manga> retrieveAllMangas() {
        return mangaService.retrieveMangas();
    }

    // Insert a new Manga entry
    @PostMapping("/insert")
    public Manga insertManga(@RequestBody Manga manga) {
        return mangaService.insertManga(manga);
    }

    // Update an existing Manga entry
    @PutMapping("/update")
    public ResponseEntity<Manga> updateManga(@RequestParam Long id, @RequestBody Manga updatedManga) {
        try {
            Manga manga = mangaService.updateManga(id, updatedManga);
            return ResponseEntity.ok(manga);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Delete a Manga entry by ID
    @DeleteMapping("/delete")
    public ResponseEntity<Void> deleteMangaById(@RequestParam Long id) {
        try {
            mangaService.deleteMangaById(id);
            return ResponseEntity.noContent().build();
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Find a Manga by ID
    @GetMapping("/getById")
    public ResponseEntity<Manga> getMangaById(@RequestParam Long id) {
        try {
            Manga manga = mangaService.getMangaById(id);
            return ResponseEntity.ok(manga);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    // Update the scores of a Manga by ID
    @PutMapping("/updateScore")
    public ResponseEntity<Manga> updateMangaScore(@RequestParam Long mangaId) {
        try {
            Manga manga = mangaService.updateMangaScore(mangaId);
            return ResponseEntity.ok(manga);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PutMapping("/updateReviews")
    public ResponseEntity<Manga> updateMangaReviews(@RequestParam Long mangaId) {
        try {
            Manga updatedManga = mangaService.updateReviewCount(mangaId);
            return ResponseEntity.ok(updatedManga);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(null); // Customize error handling as needed
        }
    }

    @GetMapping("/sortByTags")
    public List<Manga> sortMangasByTags(@RequestParam List<String> tags) {
        return mangaService.sortMangasByTags(tags);
    }

    @GetMapping("/sortByScore")
    public List<Manga> sortMangasByScore() {
        return mangaService.sortMangasByScore();
    }

    @GetMapping("/findByTitle")
    public ResponseEntity<Manga> findMangaByTitle(@RequestParam String title) {
        try {
            Manga manga = mangaService.findMangaByTitle(title);
            return ResponseEntity.ok(manga);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/findByStatus")
    public List<Manga> findMangasByStatus(@RequestParam MangaStatus status) {
        return mangaService.findMangasByStatus(status);
    }

    @GetMapping("/uniqueTags")
    public ResponseEntity<List<String>> getAllUniqueTags() {
        List<String> uniqueTags = mangaService.getAllUniqueTags();
        return ResponseEntity.ok(uniqueTags);
    }

}

