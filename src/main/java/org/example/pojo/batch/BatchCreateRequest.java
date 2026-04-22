package org.example.pojo.batch;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class BatchCreateRequest {

    private String templateFileName;
    private String runMode;
    private List<String> qaIds = new ArrayList<String>();
}
