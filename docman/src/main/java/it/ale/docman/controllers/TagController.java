package it.ale.docman.controllers;

import it.ale.docman.entities.Utente;
import it.ale.docman.services.TagService;
import it.ale.docman.services.UtenteService;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/tags")
public class TagController {
    @Autowired
    private TagService tagService;

    @Autowired
    private UtenteService utenteService;

    @GetMapping
    @PreAuthorize("hasAuthority('utente')")
    public ResponseEntity mostraTagsPerUtente() {
        try {
            Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
            return new ResponseEntity(tagService.mostraPerProprietario(proprietario), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }
}
