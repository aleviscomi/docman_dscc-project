package it.ale.docman.repositories;

import it.ale.docman.entities.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface DocumentoRepository extends JpaRepository<Documento, Integer> {
    boolean existsById(int id);
    boolean existsByPath(String path);
    boolean existsByTitolo(String titolo);
    Documento findById(int id);
    List<Documento> findByProprietarioAndTitoloContainingIgnoreCaseAndCestinoYN(Utente proprietario, String titolo, boolean cestino);
    List<Documento> findByProprietarioAndFormatoAndCestinoYN(Utente proprietario, String formato, boolean cestino);
    List<Documento> findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestinoYN(Utente proprietario, String titolo, String formato, boolean cestino);
    List<Documento> findByProprietarioAndCestinoYN(Utente proprietario, boolean cestino);

    @Query("select distinct formato from Documento where proprietario = ?1")
    List<String> findAllTypesByProprietario(Utente proprietario);
}
