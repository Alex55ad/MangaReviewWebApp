package com.utcn.manga_review.entity;

import com.utcn.manga_review.entity.MangaStatus;
import jakarta.persistence.*;
import java.util.Date;
import java.text.SimpleDateFormat;

@Entity
@Table(name = "manga")
public class Manga {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "title", nullable = false)
    private String title;

    @Column(name = "author")
    private String author;

    @Lob
    @Column(name = "tags")
    private String tags;

    @Column(name = "chapters")
    private Integer chapters;

    @Temporal(TemporalType.DATE)
    @Column(name = "release_date")
    private Date releaseDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private MangaStatus status;

    @Column(name = "score")
    private Double score;

    @Column(name = "reviews")
    private Long reviews;

    // Default constructor
    public Manga() {
    }

    // Parameterized constructor
    public Manga(Long id, String title, String author, String tags, Integer chapters, Date releaseDate, MangaStatus status, Double score, Long reviews) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.tags = tags;
        this.chapters = chapters;
        this.releaseDate = releaseDate;
        this.status = status;
        this.score = score;
        this.reviews = reviews;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getTags() {
        return tags;
    }

    public void setTags(String tags) {
        this.tags = tags;
    }

    public Integer getChapters() {
        return chapters;
    }

    public void setChapters(Integer chapters) {
        this.chapters = chapters;
    }

    public Date getReleaseDate() {
        return releaseDate;
    }

    public void setReleaseDate(Date releaseDate) {
        this.releaseDate = releaseDate;
    }

    public MangaStatus getStatus() {
        return status;
    }

    public void setStatus(MangaStatus status) {
        this.status = status;
    }

    public Double getScore() {
        return score;
    }

    public void setScore(Double score) {
        this.score = score;
    }

    public Long getReviews() {
        return reviews;
    }

    public void setReviews(Long reviews) {
        this.reviews = reviews;
    }

    public String getFormattedDate() {
        if (releaseDate == null) {
            return null; // or return an empty string "" if you prefer
        }
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(releaseDate);
    }
}

