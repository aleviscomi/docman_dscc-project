package it.ale.docman.controllers;

import it.ale.docman.services.TagService;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/tag")
public class TagController {
    @Autowired
    private TagService tagService;

    @GetMapping
    public ResponseEntity mostraTagPerProprietario(@RequestParam("id_utente") int idUtente) {
        try {
            return new ResponseEntity(tagService.mostraPerUtente(idUtente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }
}
