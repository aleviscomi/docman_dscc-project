package it.ale.docman.services;

import it.ale.docman.entities.Utente;
import it.ale.docman.repositories.UtenteRepository;
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

    @Transactional
    public Utente registraUtente(Utente utente) throws MailUserAlreadyExistsException {
        if(utenteRepository.existsByEmail(utente.getEmail()))
            throw new MailUserAlreadyExistsException();

        return utenteRepository.save(utente);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Utente> mostraTuttiTranne(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Utente utente = utenteRepository.findById(idUtente);
        List<Utente> risultato = utenteRepository.findAll();
        risultato.remove(utente);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public Utente getById(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();
        return utenteRepository.findById(idUtente);
    }
}
