package it.ale.docman.entities;

import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "documenti")
public class Documenti {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "path", length = 750, nullable = false)
    private String path;

    @Column(name = "titolo", length = 100, nullable = false)
    private String titolo;

    @Column(name = "formato", length = 10, nullable = false)
    private String formato;

    @Column(name = "data", nullable = false)
    private LocalDateTime data;

    @Column(name = "descrizione", length = 250, nullable = false)
    private String descrizione;

    @Column(name = "cestinoYN", nullable = false)
    private boolean cestinoYN;

    @ManyToOne
    @JoinColumn(name = "proprietario")
    private Utenti proprietario;

    @ManyToMany
    @JoinTable(name = "associazioni_doc_tag", joinColumns = {@JoinColumn(name = "id_documento")}, inverseJoinColumns = {@JoinColumn(name = "id_tag")})
    private List<Tags> tags;

    @ManyToMany(mappedBy = "documentiCondivisi")
    private List<Utenti> utenti;
}
