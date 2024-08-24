package com.utcn.manga_review.repository;

import com.utcn.manga_review.entity.Manga;
import com.utcn.manga_review.entity.MangaStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.repository.CrudRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MangaRepository extends JpaRepository<Manga, Long> {
    List<Manga> findByTagsContaining(String mostReviewedTag);

    List<Manga> findByStatus(MangaStatus status);

    Manga findByTitle(String title);
}

