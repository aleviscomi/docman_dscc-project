package it.ale.docman.services;

import it.ale.docman.entities.*;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.TagRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class DocumentoService {
    @Autowired
    private DocumentoRepository documentoRepository;

    @Autowired
    private UtenteRepository utenteRepository;

    @Autowired
    private TagRepository tagRepository;

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraPerUtente(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);
        return documentoRepository.findByProprietarioAndCestinoYN(proprietario, false);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCondivisiConMe(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);

        List<Documento> risultato = new ArrayList<>();
        for(Documento d : proprietario.getDocumentiCondivisi())
            if(!d.isCestinoYN())
                risultato.add(d);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCestinati(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);
        return documentoRepository.findByProprietarioAndCestinoYN(proprietario, true);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> filtra(int idUtente, String titolo, String formato, int idTag) throws UserNotExistsException, TagNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();
        if(idTag != 0 && !tagRepository.existsById(idTag))
            throw new TagNotExistsException();

        Utente utente = utenteRepository.findById(idUtente);
        Tag tag = tagRepository.findById(idTag);

        //filtra solo per titolo documento
        if(titolo != null && formato == null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestinoYN(utente, titolo, false);

        //filtra solo per formato
        if(titolo == null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndFormatoAndCestinoYN(utente, formato, false);

        //filtra solo per tag
        if(titolo == null && formato == null && tag != null) {
            return tag.getDocumenti();
        }

        //filtra per titolo e formato
        if(titolo != null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestinoYN(utente, titolo, formato, false);

        //filtra per titolo e tag
        if(titolo != null && formato == null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestinoYN(utente, titolo, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        //filtra per formato e tag
        if(titolo == null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndFormatoAndCestinoYN(utente, formato, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }


        //filtra per tutto
        if(titolo != null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for (Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestinoYN(utente, titolo, formato, false))
                if (d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        return mostraPerUtente(idUtente);
    }

    @Transactional
    public Documento carica(Documento documento) throws UserNotExistsException, DocumentTitleAlreadyExistsException, DocumentPathAlreadyExistsException{
        if(!utenteRepository.existsById(documento.getProprietario().getId()))
            throw new UserNotExistsException();
        if(documentoRepository.existsByPath(documento.getPath()))
            throw new DocumentPathAlreadyExistsException();
        if(documentoRepository.existsByTitolo(documento.getTitolo()))
            throw new DocumentTitleAlreadyExistsException();

        return documentoRepository.save(documento);
    }

    @Transactional
    public Documento elimina(int idDocumento) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        documento.setCestinoYN(true);

        return documento;
    }

    @Transactional
    public Documento ripristina(int idDocumento) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        documento.setCestinoYN(false);

        return documento;
    }

    @Transactional
    public Documento eliminaDefinitivamente(int idDocumento) throws DocumentNotExistsException, DocumentNotDeletableException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);

        if(!documento.isCestinoYN())
            throw new DocumentNotDeletableException();

        documentoRepository.delete(documento);
        return documento;
    }

    @Transactional
    public Documento condividi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentAlreadySharedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        Utente utente = utenteRepository.findById(idUtente);

        List<Documento> documentiCondivisi = utente.getDocumentiCondivisi();

        if(documentiCondivisi.contains(documento))
            throw new DocumentAlreadySharedException();

        documentiCondivisi.add(documento);

        return documento;
    }

    @Transactional
    public Documento rimuoviPermessi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        Utente utente = utenteRepository.findById(idUtente);

        List<Documento> documentiCondivisi = utente.getDocumentiCondivisi();
        documentiCondivisi.remove(documento);

        return documento;
    }

    @Transactional
    public List<Tag> mostraTags(int idDocumento) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);

        return documento.getTags();
    }

    @Transactional
    public List<String> formatiPerProprietario(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);

        return documentoRepository.findAllTypesByProprietario(proprietario);
    }
}
