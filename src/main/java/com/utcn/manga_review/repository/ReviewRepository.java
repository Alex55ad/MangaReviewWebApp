package com.utcn.manga_review.repository;

import com.utcn.manga_review.entity.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ReviewRepository extends JpaRepository<Review, Long> {
    List<Review> findByMangaId(Long mangaId);

    List<Review> findByUserId(Long userId);

    long countByMangaId(Long mangaId);
}
