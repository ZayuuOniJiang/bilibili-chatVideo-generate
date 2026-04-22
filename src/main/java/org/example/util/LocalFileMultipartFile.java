package org.example.util;

import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * 将本地文件适配为 MultipartFile，复用现有上传处理链路。
 */
public class LocalFileMultipartFile implements MultipartFile {

    private final Path path;
    private final String fieldName;
    private final String contentType;

    public LocalFileMultipartFile(Path path, String fieldName) throws IOException {
        this.path = path;
        this.fieldName = fieldName;
        String guessed = Files.probeContentType(path);
        this.contentType = guessed == null ? "application/octet-stream" : guessed;
    }

    @Override
    public String getName() {
        return fieldName;
    }

    @Override
    public String getOriginalFilename() {
        return path.getFileName().toString();
    }

    @Override
    public String getContentType() {
        return contentType;
    }

    @Override
    public boolean isEmpty() {
        try {
            return Files.size(path) == 0;
        } catch (IOException e) {
            return true;
        }
    }

    @Override
    public long getSize() {
        try {
            return Files.size(path);
        } catch (IOException e) {
            return 0;
        }
    }

    @Override
    public byte[] getBytes() throws IOException {
        return Files.readAllBytes(path);
    }

    @Override
    public InputStream getInputStream() throws IOException {
        return new ByteArrayInputStream(getBytes());
    }

    @Override
    public void transferTo(File dest) throws IOException, IllegalStateException {
        Files.copy(path, dest.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
    }
}

