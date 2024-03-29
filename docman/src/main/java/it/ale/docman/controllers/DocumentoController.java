package it.ale.docman.controllers;

import it.ale.docman.entities.Utente;
import it.ale.docman.services.DocumentoService;
import it.ale.docman.services.UtenteService;
import it.ale.docman.supports.Info;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.validation.Valid;
import java.io.IOException;
import java.util.List;

@RestController
@RequestMapping("/documenti")
@PreAuthorize("hasAuthority('utente')")
public class DocumentoController {
    @Autowired
    private DocumentoService documentoService;

    @Autowired
    private UtenteService utenteService;

    @GetMapping("/miei")
    public ResponseEntity mostraMieiDocumenti() {
        Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
        try {
            return new ResponseEntity(documentoService.mostraPerUtente(proprietario), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/condivisiconme")
    public ResponseEntity mostraDocumentiCondivisiConMe() {
        try {
            Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
            return new ResponseEntity(documentoService.mostraCondivisiConMe(proprietario), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/cestino")
    public ResponseEntity mostraDocumentiCestinati() {
        try {
            Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
            return new ResponseEntity(documentoService.mostraCestinati(proprietario), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping(path = "/carica", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity caricaDocumento(@RequestParam String titolo, @RequestParam String descrizione, @RequestParam MultipartFile file) {
        try {
            return new ResponseEntity(documentoService.carica(titolo, descrizione, file), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentTitleAlreadyExistsException e) {
            return new ResponseEntity("Titolo già esistente!", HttpStatus.BAD_REQUEST);
        } catch (IOException e) {
            return new ResponseEntity("Errore sconosciuto!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping(value = "/scarica")
    public ResponseEntity<ByteArrayResource> scaricaDocumento(@RequestParam int idDoc) {
        try {
            return documentoService.scarica(idDoc);
        } catch (IOException e) {
            return new ResponseEntity("Errore sconosciuto!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/elimina")
    public ResponseEntity eliminaDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.elimina(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/ripristina")
    public ResponseEntity ripristinaDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.ripristina(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/eliminadefinitivamente")
    public ResponseEntity eliminaDefinitivamenteDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.eliminaDefinitivamente(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotDeletableException e) {
            return new ResponseEntity("Documento non eliminabile!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/condividi")
    public ResponseEntity condividiDocumento(@RequestParam("id_doc") int idDocumento, @RequestParam("id_utente") int idUtente) {
        try {
            return new ResponseEntity(documentoService.condividi(idDocumento, idUtente), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentAlreadySharedException e) {
            return new ResponseEntity("Questo documento è già condiviso con l'utente specificato!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        } catch (DocumentAlreadyOwnedException e) {
            return new ResponseEntity("Questo documento è già di tua proprietà! Non puoi condividere il documento con te stesso!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/rimuoviaccesso")
    public ResponseEntity rimuoviAccessoDocumento(@RequestParam("id_doc") int idDocumento, @RequestParam("id_utente") int idUtente) {
        try {
            return new ResponseEntity(documentoService.rimuoviPermessi(idDocumento, idUtente), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/tagsDocumento")
    public ResponseEntity mostraTagsDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.mostraTags(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/formato")
    public ResponseEntity mostraFormatiPerProprietario() {
        try {
            Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
            return new ResponseEntity(documentoService.formatiPerProprietario(proprietario), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/filtra")
    public ResponseEntity filtraDocumenti(@RequestParam(value = "titolo", required = false) String titolo, @RequestParam(value = "formato", required = false) String formato, @RequestParam(value = "tag", defaultValue = "0") int idTag) {
        try {
            Utente proprietario = utenteService.trovaPerEmail(Utils.getEmail());
            return new ResponseEntity(documentoService.filtra(proprietario, titolo, formato, idTag), HttpStatus.OK);
        } catch (TagNotExistsException e) {
            return new ResponseEntity("Tag inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/aggiungitags")
    public ResponseEntity aggiungiTagsDocumento(@RequestBody @Valid List<String> tags, @RequestParam("doc") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.aggiungiTags(tags, idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }

    @PutMapping("/modificainfo")
    public ResponseEntity modificaInfoDocumento(@RequestBody @Valid Info info, @RequestParam("doc") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.modificaInfo(info, idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentNotOwnedException e) {
            return new ResponseEntity("Questo documento non è di tua proprietà!", HttpStatus.BAD_REQUEST);
        }
    }
}
