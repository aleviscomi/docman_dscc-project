package it.ale.docman.services;

import it.ale.docman.entities.Tag;
import it.ale.docman.entities.Utente;
import it.ale.docman.repositories.TagRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TagService {
    @Autowired
    private TagRepository tagRepository;
    @Autowired
    private UtenteRepository utenteRepository;

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Tag> mostraTutti() {
        return tagRepository.findAll();
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Tag> mostraPerUtente(int idUtente) throws UserNotExistsException {
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Utente proprietario = utenteRepository.findById(idUtente);
        return tagRepository.findByProprietario(proprietario);
    }
}
