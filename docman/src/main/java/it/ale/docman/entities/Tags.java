package it.ale.docman.entities;

import lombok.Data;
import org.w3c.dom.stylesheets.LinkStyle;

import javax.persistence.*;
import java.util.List;

@Entity
@Data
@Table(name = "tags")
public class Tags {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "nome", length = 45, nullable = false)
    private int nome;

    @ManyToMany(mappedBy = "tags")
    private List<Documenti> documenti;
}
