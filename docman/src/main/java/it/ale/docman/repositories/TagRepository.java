package it.ale.docman.repositories;

import it.ale.docman.entities.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TagRepository extends JpaRepository<Tag, Integer> {
    boolean existsById(int id);
    boolean existsByNomeAndProprietario(String nome, Utente proprietario);
    Tag findById(int id);
    Tag findByNomeAndProprietario(String nome, Utente proprietario);
    List<Tag> findByProprietario(Utente proprietario);
    List<Tag> findAll();
}
