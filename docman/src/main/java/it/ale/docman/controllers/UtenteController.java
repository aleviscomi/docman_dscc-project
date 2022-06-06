package it.ale.docman.controllers;

import it.ale.docman.entities.Utente;
import it.ale.docman.services.UtenteService;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.DocumentNotExistsException;
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

    @PostMapping("/registra")
    public ResponseEntity registraUtente(@RequestBody @Valid Utente utente) {
        try{
            return new ResponseEntity(utenteService.registra(utente), HttpStatus.OK);
        } catch (MailUserAlreadyExistsException e) {
            return new ResponseEntity("Mail già esistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/modifica")
    @PreAuthorize("hasAuthority('utente')")
    public ResponseEntity modificaUtente(@RequestBody @Valid Utente utente) {
        try{
            return new ResponseEntity(utenteService.modificaUtente(utente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (MailUserAlreadyExistsException e) {
            return new ResponseEntity("Mail già esistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/dacondividere")
    @PreAuthorize("hasAuthority('utente')")
    public ResponseEntity utentiPerCondivisione(@RequestParam("id_doc") int idDoc) {
        try{
            return new ResponseEntity(utenteService.mostraUtentiCondivisione(idDoc), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/giacondivisi")
    @PreAuthorize("hasAuthority('utente')")
    public ResponseEntity utentiGiaCondivisi(@RequestParam("id_doc") int idDoc) {
        try{
            return new ResponseEntity(utenteService.mostraUtentiGiaCondivisi(idDoc), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        }
    }
}
