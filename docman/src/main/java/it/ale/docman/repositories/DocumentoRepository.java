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
    List<Documento> findByProprietario(Utente proprietario);
    List<Documento> findByFormato(String formato);
    List<Documento> findByData(LocalDateTime data);
    List<Documento> findByProprietarioAndCestinoYN(Utente proprietario, boolean cestino);

    @Query("select distinct formato from Documento")
    List<String> findAllTypes();
}
