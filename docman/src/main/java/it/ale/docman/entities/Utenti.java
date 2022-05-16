package it.ale.docman.entities;

import lombok.Data;

import javax.persistence.*;
import java.util.List;

@Entity
@Data
@Table(name = "utenti")
public class Utenti {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "nome", length = 50, nullable = false)
    private String nome;

    @Column(name = "cognome", length = 50, nullable = false)
    private String cognome;

    @Column(name = "email", length = 50, nullable = false)
    private String email;

    @ManyToMany
    @JoinTable(name = "documenti_condivisi", joinColumns = {@JoinColumn(name = "id_utente")}, inverseJoinColumns = {@JoinColumn(name = "id_documento")})
    private List<Documenti> documentiCondivisi;
}
