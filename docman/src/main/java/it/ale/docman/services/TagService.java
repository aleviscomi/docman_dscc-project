package it.ale.docman.services;

import it.ale.docman.entities.Tag;
import it.ale.docman.repositories.TagRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class TagService {
    @Autowired
    private TagRepository tagRepository;

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Tag> mostraTutti() {
        return tagRepository.findAll();
    }
}
