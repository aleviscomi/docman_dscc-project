package it.ale.docman.supports;
import lombok.Data;
import java.util.List;

@Data
public class Info {
    String descrizione;
    List<String> tags;

    public Info(String descrizione, List<String> tags) {
        this.descrizione = descrizione;
        this.tags = tags;
    }
}
