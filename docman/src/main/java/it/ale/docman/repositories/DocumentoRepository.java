package it.ale.docman.repositories;

import it.ale.docman.entities.*;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentoRepository extends JpaRepository<Documento, Integer> {
    boolean existsById(int id);
    boolean existsByTitolo(String titolo);
    Documento findById(int id);
    List<Documento> findByProprietarioAndTitoloContainingIgnoreCaseAndCestino(Utente proprietario, String titolo, boolean cestino);
    List<Documento> findByProprietarioAndFormatoAndCestino(Utente proprietario, String formato, boolean cestino);
    List<Documento> findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestino(Utente proprietario, String titolo, String formato, boolean cestino);
    List<Documento> findByProprietarioAndCestinoOrderByDataDesc(Utente proprietario, boolean cestino);

    @Query("select distinct formato from Documento where proprietario = ?1")
    List<String> findAllTypesByProprietario(Utente proprietario);
}
