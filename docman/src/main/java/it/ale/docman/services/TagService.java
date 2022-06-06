package it.ale.docman.services;

import it.ale.docman.entities.Documento;
import it.ale.docman.entities.Tag;
import it.ale.docman.entities.Utente;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.TagRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class TagService {
    @Autowired
    private TagRepository tagRepository;
    @Autowired
    private UtenteRepository utenteRepository;
    @Autowired
    private DocumentoService documentoService;

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Tag> mostraTutti() {
        return tagRepository.findAll();
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Tag> mostraPerProprietario(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId()))
            throw new UserNotExistsException();

        List<Tag> tagsProprietario = tagRepository.findByProprietario(proprietario);
        List<Documento> documentiProprietario = documentoService.mostraPerUtente(proprietario);
        List<Tag> result = new ArrayList<>();

        for(Tag t : tagsProprietario)
            for(Documento d : documentiProprietario)
                if(d.getTags().contains(t)) {
                    result.add(t);
                    break;
                }

        return result;
    }
}
