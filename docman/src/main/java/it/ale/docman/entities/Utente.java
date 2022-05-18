package it.ale.docman.entities;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.Data;

import javax.persistence.*;
import java.util.List;

@Entity
@Data
@Table(name = "utenti")
public class Utente {
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
    @JsonIgnore
    private List<Documento> documentiCondivisi;
}
