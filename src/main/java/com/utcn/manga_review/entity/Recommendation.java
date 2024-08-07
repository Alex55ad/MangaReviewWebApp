package com.utcn.manga_review.entity;

import jakarta.persistence.*;
import java.util.Date;

@Entity
@Table(name = "recommendation")
public class Recommendation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne
    @JoinColumn(name = "manga_id", nullable = false)
    private Manga manga;

    @Lob
    @Column(name = "reason")
    private String reason;

    // Default constructor
    public Recommendation() {
    }

    // Parameterized constructor
    public Recommendation(Long id, User user, Manga manga, String reason) {
        this.id = id;
        this.user = user;
        this.manga = manga;
        this.reason = reason;
    }

    // Getters and setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Manga getManga() {
        return manga;
    }

    public void setManga(Manga manga) {
        this.manga = manga;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }
}

