package it.ale.docman.services;

import it.ale.docman.entities.Documento;
import it.ale.docman.entities.Utente;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.DocumentNotExistsException;
import it.ale.docman.supports.exceptions.MailUserAlreadyExistsException;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UtenteService {
    @Autowired
    private UtenteRepository utenteRepository;

    @Autowired
    private DocumentoRepository documentoRepository;

    @Transactional
    public Utente registra(Utente utente) throws MailUserAlreadyExistsException {
        if(utenteRepository.existsByEmail(utente.getEmail()))
            throw new MailUserAlreadyExistsException();

        return utenteRepository.save(utente);
    }

    @Transactional
    public Utente modificaUtente(Utente utente) throws UserNotExistsException, MailUserAlreadyExistsException {
        if(!utenteRepository.existsById(utente.getId()))
            throw new UserNotExistsException();
        Utente checkEmail = utenteRepository.findByEmail(utente.getEmail());
        if(checkEmail != null && checkEmail.getId() != utente.getId())
            throw new MailUserAlreadyExistsException();

        Utente old = utenteRepository.findById(utente.getId());
        old.setNome(utente.getNome());
        old.setCognome(utente.getCognome());
        old.setEmail(utente.getEmail());

        return old;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Utente> mostraUtentiCondivisione(int idDoc) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDoc))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDoc);
        List<Utente> inCondivisione = documento.getUtenti();
        Utente utenteLoggato = utenteRepository.findByEmail(Utils.getEmail());

        List<Utente> risultato = utenteRepository.findAll();
        risultato.remove(utenteLoggato);
        for(Utente u : inCondivisione)
            risultato.remove(u);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Utente> mostraUtentiGiaCondivisi(int idDoc) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDoc))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDoc);

        return documento.getUtenti();
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public Utente trovaPerId(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();
        return utenteRepository.findById(idUtente);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public Utente trovaPerEmail(String email) throws UserNotExistsException {
        if(!utenteRepository.existsByEmail(email))
            throw new UserNotExistsException();
        return utenteRepository.findByEmail(email);
    }
}
