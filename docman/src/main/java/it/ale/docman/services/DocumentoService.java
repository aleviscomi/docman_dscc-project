package it.ale.docman.services;

import it.ale.docman.entities.*;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.TagRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

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
    public List<Documento> mostraPerUtente(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        return documentoRepository.findByProprietarioAndCestinoOrderByDataDesc(proprietario, false);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCondivisiConMe(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        List<Documento> risultato = new ArrayList<>();
        for(Documento d : proprietario.getDocumentiCondivisi())
            if(!d.isCestino())
                risultato.add(d);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCestinati(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        return documentoRepository.findByProprietarioAndCestinoOrderByDataDesc(proprietario, true);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> filtra(Utente proprietario, String titolo, String formato, int idTag) throws TagNotExistsException {
        if(idTag != 0 && !tagRepository.existsById(idTag))
            throw new TagNotExistsException();

        Tag tag = tagRepository.findById(idTag);

        //filtra solo per titolo documento
        if(titolo != null && formato == null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestino(proprietario, titolo, false);

        //filtra solo per formato
        if(titolo == null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndFormatoAndCestino(proprietario, formato, false);

        //filtra solo per tag
        if(titolo == null && formato == null && tag != null) {
            return tag.getDocumenti();
        }

        //filtra per titolo e formato
        if(titolo != null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestino(proprietario, titolo, formato, false);

        //filtra per titolo e tag
        if(titolo != null && formato == null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestino(proprietario, titolo, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        //filtra per formato e tag
        if(titolo == null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndFormatoAndCestino(proprietario, formato, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }


        //filtra per tutto
        if(titolo != null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for (Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestino(proprietario, titolo, formato, false))
                if (d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        return mostraPerUtente(proprietario);
    }

    @Transactional
    public Documento carica(Documento documento) throws UserNotExistsException, DocumentTitleAlreadyExistsException, DocumentUrlAlreadyExistsException {
        if(!utenteRepository.existsById(documento.getProprietario().getId()))
            throw new UserNotExistsException();
        if(documentoRepository.existsByUrl(documento.getUrl()))
            throw new DocumentUrlAlreadyExistsException();
        if(documentoRepository.existsByTitolo(documento.getTitolo()))
            throw new DocumentTitleAlreadyExistsException();

        return documentoRepository.save(documento);
    }

    @Transactional
    public Documento elimina(int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();
        documento.setCestino(true);

        return documento;
    }

    @Transactional
    public Documento ripristina(int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();
        documento.setCestino(false);

        return documento;
    }

    @Transactional
    public Documento eliminaDefinitivamente(int idDocumento) throws DocumentNotExistsException, DocumentNotDeletableException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();

        if(!documento.isCestino())
            throw new DocumentNotDeletableException();

        documentoRepository.delete(documento);
        return documento;
    }

    @Transactional
    public Documento condividi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentAlreadySharedException, DocumentNotOwnedException, DocumentAlreadyOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();
        if(idUtente == utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentAlreadyOwnedException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();

        if(documento.isCestino())
            throw new DocumentNotExistsException();

        Utente utente = utenteRepository.findById(idUtente);

        List<Documento> documentiCondivisi = utente.getDocumentiCondivisi();

        if(documentiCondivisi.contains(documento))
            throw new DocumentAlreadySharedException();

        documentiCondivisi.add(documento);

        return documento;
    }

    @Transactional
    public Documento rimuoviPermessi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();

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
    public List<String> formatiPerProprietario(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId()))
            throw new UserNotExistsException();

        return documentoRepository.findAllTypesByProprietario(proprietario);
    }

    @Transactional
    public String aggiungiTags(List<Tag> tags, int idDocumento) throws DocumentNotExistsException, TagNotExistsException, DocumentNotOwnedException  {
        Utente utente = utenteRepository.findByEmail(Utils.getEmail());
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        for(Tag t : tags)
            if(!tagRepository.existsById(t.getId()) || tagRepository.findById(t.getId()).getProprietario().getId() != utente.getId())
                throw new TagNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utente.getId())
            throw new DocumentNotOwnedException();

        List<Tag> listaTag = documento.getTags();
        listaTag.addAll(tags);

        return "Documento " + idDocumento + ": tags aggiunti!";
    }

    @Transactional
    public String rimuoviTag(int idTag, int idDocumento) throws DocumentNotExistsException, TagNotExistsException, DocumentNotOwnedException  {
        Utente utente = utenteRepository.findByEmail(Utils.getEmail());
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        if(!tagRepository.existsById(idTag))
            throw new TagNotExistsException();

        Tag tag = tagRepository.findById(idTag);

        if(tag.getProprietario().getId() != utente.getId())
            throw new TagNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utente.getId())
            throw new DocumentNotOwnedException();

        List<Tag> listaTag = documento.getTags();
        listaTag.remove(tag);

        return "Documento " + idDocumento + ": tag " + idTag + " rimosso!";
    }
}
