package com.utcn.manga_review.entity;

import com.utcn.manga_review.entity.MangaStatus;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;
import java.text.SimpleDateFormat;

@Entity
@Builder
@Data
@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
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

    @Column(name = "cover")
    private String cover;

    public String getFormattedDate() {
        if (releaseDate == null) {
            return null; // or return an empty string "" if you prefer
        }
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
        return sdf.format(releaseDate);
    }
}

