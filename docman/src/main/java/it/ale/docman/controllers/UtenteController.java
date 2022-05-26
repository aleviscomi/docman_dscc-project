package it.ale.docman.controllers;

import it.ale.docman.entities.Utente;
import it.ale.docman.services.UtenteService;
import it.ale.docman.supports.exceptions.MailUserAlreadyExistsException;
import it.ale.docman.supports.exceptions.UserNotExistsException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/utenti")
public class UtenteController {
    @Autowired
    private UtenteService utenteService;

    @PostMapping
    public ResponseEntity register(@RequestBody @Valid Utente utente) {
        try{
            return new ResponseEntity(utenteService.registra(utente), HttpStatus.OK);
        } catch (MailUserAlreadyExistsException e) {
            return new ResponseEntity("Mail già esistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/modify")
    @PreAuthorize("hasAuthority('client')")
    public ResponseEntity modify(@RequestBody @Valid Utente utente) {
        try{
            return new ResponseEntity(utenteService.modificaUtente(utente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (MailUserAlreadyExistsException e) {
            return new ResponseEntity("Mail già esistente!", HttpStatus.BAD_REQUEST);
        }
    }
}
