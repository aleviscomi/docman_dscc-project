package it.ale.docman.services;

import it.ale.docman.entities.*;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.UtenteRepository;
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

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraMieiDocumenti(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);
        return documentoRepository.findByProprietarioAndCestinoYN(proprietario, false);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraDocumentiCondivisiConMe(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);

        List<Documento> risultato = new ArrayList<>();
        for(Documento d : proprietario.getDocumentiCondivisi())
            if(!d.isCestinoYN())
                risultato.add(d);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraDocumentiCestinati(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente)) throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);
        return documentoRepository.findByProprietarioAndCestinoYN(proprietario, true);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> filtraDocumentiPerNomeAndFormatoAndTagAndData() {
        // TODO
        return null;
    }

    @Transactional
    public Documento caricaDocumento(Documento documento) throws UserNotExistsException, DocumentTitleAlreadyExistsException, DocumentPathAlreadyExistsException{
        if(!utenteRepository.existsById(documento.getProprietario().getId()))
            throw new UserNotExistsException();
        if(documentoRepository.existsByPath(documento.getPath()))
            throw new DocumentPathAlreadyExistsException();
        if(documentoRepository.existsByTitolo(documento.getTitolo()))
            throw new DocumentTitleAlreadyExistsException();

        return documentoRepository.save(documento);
    }

    @Transactional
    public Documento eliminaDocumento(int idDocumento) throws DocumentNotExistsException {
        if(documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        documento.setCestinoYN(true);

        return documento;
    }

    @Transactional
    public Documento ripristinaDocumento(int idDocumento) throws DocumentNotExistsException {
        if(documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        documento.setCestinoYN(false);

        return documento;
    }

    @Transactional
    public Documento eliminaDefinitivamenteDocumento(int idDocumento) throws DocumentNotExistsException, DocumentNotDeletableException {
        if(documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);

        if(!documento.isCestinoYN())
            throw new DocumentNotDeletableException();

        documentoRepository.delete(documento);
        return documento;
    }

    @Transactional
    public Documento condividiDocumento(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentAlreadySharedException {
        if(documentoRepository.existsById(idDocumento))
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
        if(documentoRepository.existsById(idDocumento))
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
    public List<Tag> tagsDocumento(int idDocumento) throws DocumentNotExistsException {
        if(documentoRepository.existsById(idDocumento))
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
