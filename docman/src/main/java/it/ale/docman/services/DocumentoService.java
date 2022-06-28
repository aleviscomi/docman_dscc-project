package it.ale.docman.services;

import it.ale.docman.entities.*;
import it.ale.docman.repositories.DocumentoRepository;
import it.ale.docman.repositories.TagRepository;
import it.ale.docman.repositories.UtenteRepository;
import it.ale.docman.supports.Info;
import it.ale.docman.supports.authentication.Utils;
import it.ale.docman.supports.exceptions.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class DocumentoService {
    @Autowired
    private DocumentoRepository documentoRepository;

    @Autowired
    private UtenteRepository utenteRepository;

    @Autowired
    private TagRepository tagRepository;

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraPerUtente(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        return documentoRepository.findByProprietarioAndCestinoOrderByDataDesc(proprietario, false);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCondivisiConMe(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        List<Documento> risultato = new ArrayList<>();
        for(Documento d : proprietario.getDocumentiCondivisi())
            if(!d.isCestino())
                risultato.add(d);

        return risultato;
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> mostraCestinati(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId())) throw new UserNotExistsException();

        return documentoRepository.findByProprietarioAndCestinoOrderByDataDesc(proprietario, true);
    }

    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public List<Documento> filtra(Utente proprietario, String titolo, String formato, int idTag) throws TagNotExistsException {
        if(idTag != 0 && !tagRepository.existsById(idTag))
            throw new TagNotExistsException();

        Tag tag = tagRepository.findById(idTag);

        //filtra solo per titolo documento
        if(titolo != null && formato == null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestino(proprietario, titolo, false);

        //filtra solo per formato
        if(titolo == null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndFormatoAndCestino(proprietario, formato, false);

        //filtra solo per tag
        if(titolo == null && formato == null && tag != null) {
            return tag.getDocumenti();
        }

        //filtra per titolo e formato
        if(titolo != null && formato != null && tag == null)
            return documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestino(proprietario, titolo, formato, false);

        //filtra per titolo e tag
        if(titolo != null && formato == null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndCestino(proprietario, titolo, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        //filtra per formato e tag
        if(titolo == null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for(Documento d : documentoRepository.findByProprietarioAndFormatoAndCestino(proprietario, formato, false))
                if(d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }


        //filtra per tutto
        if(titolo != null && formato != null && tag != null) {
            List<Documento> risultato = new ArrayList<>();
            for (Documento d : documentoRepository.findByProprietarioAndTitoloContainingIgnoreCaseAndFormatoAndCestino(proprietario, titolo, formato, false))
                if (d.getTags().contains(tag))
                    risultato.add(d);
            return risultato;
        }

        return mostraPerUtente(proprietario);
    }

    @Transactional
    public Documento carica(String titolo, String descrizione, MultipartFile file) throws UserNotExistsException, DocumentTitleAlreadyExistsException, DocumentUrlAlreadyExistsException, IOException {
        Utente proprietario = utenteRepository.findByEmail(Utils.getEmail());
        if(proprietario == null)
            throw new UserNotExistsException();

        int dotIndex = file.getOriginalFilename().lastIndexOf(".");
        String extension;
        if(dotIndex != -1)
            extension = file.getOriginalFilename().substring(dotIndex + 1);
        else
            extension = "";
        String url = "C:/Users/aless/IdeaProjects/SDCCproject/docman/src/main/resources/uploadedFiles/";

        Documento documento = new Documento();
        if(extension.equals(""))
            documento.setUrl(url+titolo);
        else
            documento.setUrl(url+titolo+"."+extension);
        documento.setTitolo(titolo);
        documento.setFormato(extension);
        documento.setData(LocalDateTime.now());
        documento.setDescrizione(descrizione);
        documento.setDimensione(Integer.parseInt(bytesToSize(file.getSize())[0]));
        documento.setUnita_dimensione(bytesToSize(file.getSize())[1]);
        documento.setCestino(false);
        documento.setProprietario(proprietario);

        if(documentoRepository.existsByUrl(documento.getUrl()))
            throw new DocumentUrlAlreadyExistsException();
        if(documentoRepository.existsByTitolo(documento.getTitolo()))
            throw new DocumentTitleAlreadyExistsException();

        if(extension.equals(""))
            file.transferTo(new File(url+titolo));
        else
            file.transferTo(new File(url+titolo+"."+extension));
        return documentoRepository.save(documento);
    }

    @Transactional
    public Documento elimina(int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();
        documento.setCestino(true);

        return documento;
    }

    @Transactional
    public Documento ripristina(int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();
        documento.setCestino(false);

        return documento;
    }

    @Transactional
    public Documento eliminaDefinitivamente(int idDocumento) throws DocumentNotExistsException, DocumentNotDeletableException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();

        if(!documento.isCestino())
            throw new DocumentNotDeletableException();

        documentoRepository.delete(documento);
        return documento;
    }

    @Transactional
    public Documento condividi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentAlreadySharedException, DocumentNotOwnedException, DocumentAlreadyOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();
        if(idUtente == utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentAlreadyOwnedException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId())
            throw new DocumentNotOwnedException();

        if(documento.isCestino())
            throw new DocumentNotExistsException();

        Utente utente = utenteRepository.findById(idUtente);

        List<Documento> documentiCondivisi = utente.getDocumentiCondivisi();

        if(documentiCondivisi.contains(documento))
            throw new DocumentAlreadySharedException();

        documentiCondivisi.add(documento);

        return documento;
    }

    @Transactional
    public Documento rimuoviPermessi(int idDocumento, int idUtente) throws DocumentNotExistsException, UserNotExistsException, DocumentNotOwnedException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();
        if(!utenteRepository.existsById(idUtente))
            throw new UserNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        Utente utente = utenteRepository.findById(idUtente);

        if(documento.getProprietario().getId() != utenteRepository.findByEmail(Utils.getEmail()).getId() &&
           !documento.getUtenti().contains(utente))
            throw new DocumentNotOwnedException();


        List<Documento> documentiCondivisi = utente.getDocumentiCondivisi();
        documentiCondivisi.remove(documento);

        return documento;
    }

    @Transactional
    public List<Tag> mostraTags(int idDocumento) throws DocumentNotExistsException {
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);

        return documento.getTags();
    }

    @Transactional
    public List<String> formatiPerProprietario(Utente proprietario) throws UserNotExistsException {
        if(!utenteRepository.existsById(proprietario.getId()))
            throw new UserNotExistsException();

        List<String> formatiProprietario = documentoRepository.findAllTypesByProprietario(proprietario);
        List<Documento> documentiProprietario = mostraPerUtente(proprietario);
        List<String> result = new ArrayList<>();

        for(String s : formatiProprietario)
            for(Documento d : documentiProprietario)
                if(d.getFormato().equals(s)) {
                    result.add(s);
                    break;
                }

        return result;
    }

    @Transactional
    public String aggiungiTags(List<String> tags, int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException  {
        Utente utente = utenteRepository.findByEmail(Utils.getEmail());
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utente.getId())
            throw new DocumentNotOwnedException();


        List<Tag> tagDaAggiungere = new ArrayList<>();
        for(String t : tags) {
            if (!tagRepository.existsByNomeAndProprietario(t, utente)) {
                Tag nuovo = new Tag();
                nuovo.setNome(t);
                nuovo.setProprietario(utente);
                tagRepository.save(nuovo);
                tagDaAggiungere.add(nuovo);
            } else
                tagDaAggiungere.add(tagRepository.findByNomeAndProprietario(t, utente));
        }

        List<Tag> listaTag = documento.getTags();
        listaTag.addAll(tagDaAggiungere);

        return "Documento " + idDocumento + ": tags aggiunti!";
    }

    @Transactional
    public String modificaInfo(Info info, int idDocumento) throws DocumentNotExistsException, DocumentNotOwnedException  {
        Utente utente = utenteRepository.findByEmail(Utils.getEmail());
        if(!documentoRepository.existsById(idDocumento))
            throw new DocumentNotExistsException();

        Documento documento = documentoRepository.findById(idDocumento);
        if(documento.getProprietario().getId() != utente.getId())
            throw new DocumentNotOwnedException();

        documento.setDescrizione(info.getDescrizione());

        List<Tag> tagDaAggiungere = new ArrayList<>();
        for(String t : info.getTags()) {
            if (!tagRepository.existsByNomeAndProprietario(t, utente)) {
                Tag nuovo = new Tag();
                nuovo.setNome(t);
                nuovo.setProprietario(utente);
                tagRepository.save(nuovo);
                tagDaAggiungere.add(nuovo);
            } else
                tagDaAggiungere.add(tagRepository.findByNomeAndProprietario(t, utente));
        }

        List<Tag> listaTag = documento.getTags();
        listaTag.clear();
        listaTag.addAll(tagDaAggiungere);

        return "Documento " + idDocumento + ": tags modificati!";
    }

    private String[] bytesToSize(long bytes) {
        String sizes[] = {"B", "KB", "MB", "GB", "TB"};
        if (bytes == 0) return new String[]{String.valueOf(0), "B"};
        int i = (int) Math.floor(Math.log(bytes) / Math.log(1024));
        return new String[]{String.valueOf(Math.round(bytes / Math.pow(1024, i))), sizes[i]};
    }
}
