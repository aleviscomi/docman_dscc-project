package it.ale.docman.repositories;

import it.ale.docman.entities.Utente;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UtenteRepository extends JpaRepository<Utente, Integer> {
    boolean existsById(int id);
    Utente findById(int id);
    boolean existsByEmail(String email);
    Utente findByEmail(String email);
    List<Utente> findAll();
}
