package it.ale.docman.controllers;

import it.ale.docman.entities.Documento;
import it.ale.docman.services.DocumentoService;
import it.ale.docman.services.TagService;
import it.ale.docman.supports.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;

@RestController
@RequestMapping("/documents")
public class DocumentoController {
    @Autowired
    private DocumentoService documentoService;

    @Autowired
    private TagService tagService;

    @GetMapping("/miei")
    public ResponseEntity mostraMieiDocumenti(@RequestParam("id") int idUtente) {
        try {
            return new ResponseEntity(documentoService.mostraPerUtente(idUtente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/condivisiconme")
    public ResponseEntity mostraDocumentiCondivisiConMe(@RequestParam("id") int idUtente) {
        try {
            return new ResponseEntity(documentoService.mostraCondivisiConMe(idUtente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/cestino")
    public ResponseEntity mostraDocumentiCestinati(@RequestParam("id") int idUtente) {
        try {
            return new ResponseEntity(documentoService.mostraCestinati(idUtente), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/carica")
    public ResponseEntity caricaDocumento(@RequestBody @Valid Documento documento) {
        try {
            return new ResponseEntity(documentoService.carica(documento), HttpStatus.OK);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentTitleAlreadyExistsException e) {
            return new ResponseEntity("Titolo già esistente!", HttpStatus.BAD_REQUEST);
        } catch (DocumentPathAlreadyExistsException e) {
            return new ResponseEntity("Path già esistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @DeleteMapping("/elimina")
    public ResponseEntity eliminaDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.elimina(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/ripristina")
    public ResponseEntity ripristinaDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.ripristina(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
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
        }
    }

    @PostMapping("/rimuoviaccesso")
    public ResponseEntity rimuoviAccessoDocumento(@RequestParam("id_doc") int idDocumento, @RequestParam("id_utente") int idUtente) {
        try {
            return new ResponseEntity(documentoService.rimuoviPermessi(idDocumento, idUtente), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/tagsDocumento")
    public ResponseEntity mostraTagsDocumento(@RequestParam("id") int idDocumento) {
        try {
            return new ResponseEntity(documentoService.mostraTags(idDocumento), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/tagsUtente")
    public ResponseEntity mostraTagsPerUtente(@RequestParam("id") int idUtente) {
        try {
            return new ResponseEntity(tagService.mostraPerUtente(idUtente), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/formato")
    public ResponseEntity mostraFormatiDocumentoPerProprietario(@RequestParam("id_utente") int idUtente) {
        try {
            return new ResponseEntity(documentoService.formatiPerProprietario(idUtente), HttpStatus.OK);
        } catch (DocumentNotExistsException e) {
            return new ResponseEntity("Documento inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }

    @GetMapping("/filtra")
    public ResponseEntity filtraDocumenti(@RequestParam("id_utente") int idUtente, @RequestParam(value = "titolo", required = false) String titolo, @RequestParam(value = "formato", required = false) String formato, @RequestParam(value = "id_tag", defaultValue = "0") int idTag) {
        try {
            return new ResponseEntity(documentoService.filtra(idUtente, titolo, formato, idTag), HttpStatus.OK);
        } catch (TagNotExistsException e) {
            return new ResponseEntity("Tag inesistente!", HttpStatus.BAD_REQUEST);
        } catch (UserNotExistsException e) {
            return new ResponseEntity("Utente inesistente!", HttpStatus.BAD_REQUEST);
        }
    }
}
