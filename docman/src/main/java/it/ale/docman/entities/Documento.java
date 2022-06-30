package it.ale.docman.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Data
@Table(name = "documenti")
public class Documento {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "titolo", length = 100, nullable = false)
    private String titolo;

    @Column(name = "formato", length = 10, nullable = false)
    private String formato;

    @Column(name = "data", nullable = false)
    private LocalDateTime data;

    @Column(name = "descrizione", length = 250, nullable = false)
    private String descrizione;

    @Column(name = "dimensione", nullable = false)
    private int dimensione;

    @Column(name = "unita_dimensione", length = 2, nullable = false)
    private String unita_dimensione;

    @Column(name = "cestinoYN", nullable = false)
    private boolean cestino;

    @ManyToOne
    @JoinColumn(name = "proprietario")
    private Utente proprietario;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(name = "associazioni_doc_tag", joinColumns = {@JoinColumn(name = "id_documento")}, inverseJoinColumns = {@JoinColumn(name = "id_tag")})
    private List<Tag> tags;

    @ManyToMany(mappedBy = "documentiCondivisi")
    private List<Utente> utenti;
}
