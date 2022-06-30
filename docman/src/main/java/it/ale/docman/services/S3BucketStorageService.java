package it.ale.docman.services;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.util.IOUtils;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Objects;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
public class S3BucketStorageService {
    private static final Logger LOG = LoggerFactory.getLogger(S3BucketStorageService.class);

    @Autowired
    private AmazonS3 amazonS3;

    @Value("${application.bucket.name}")
    private String bucketName;

    public String uploadFileToS3(MultipartFile file, String fileName) {
        String uploadMessage = "File upload failed";
        File fileObj = convertMultiPartFileToFile(file);
        // String fileName = System.currentTimeMillis() + "_" + file.getOriginalFilename();
        String originalFileName = file.getOriginalFilename();
        int dotIndex = originalFileName.lastIndexOf('.');
        String extension;
        if(dotIndex != -1)
            extension = originalFileName.substring(dotIndex);
        else
            extension = "";
        PutObjectResult putObjectResult = amazonS3
                .putObject(new PutObjectRequest(bucketName, fileName + extension, fileObj));
        fileObj.delete();
        if (Objects.nonNull(putObjectResult)) {
            return "file with name " + fileName + " successfully uploaded to S3.";
        }
        return uploadMessage;
    }

    public byte[] downloadFileFromS3(String fileName) {
        S3Object s3Object = amazonS3.getObject(bucketName, fileName);
        S3ObjectInputStream inputStream = s3Object.getObjectContent();
        try {
            byte[] content = IOUtils.toByteArray(inputStream);
            return content;
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    public String deleteFileFromS3(String fileName) {
        amazonS3.deleteObject(bucketName, fileName);
        return fileName + " removed ...";
    }

    private File convertMultiPartFileToFile(MultipartFile file) {
        File convertedFile = new File(file.getOriginalFilename());
        try (FileOutputStream fos = new FileOutputStream(convertedFile)) {
            fos.write(file.getBytes());
        } catch (IOException e) {
            LOG.error("Error converting multipartFile to file", e);
        }
        return convertedFile;
    }
}
