package threads;

import java.io.*;
import java.net.Socket;
import java.util.Date;

public class ServerThreads implements Runnable {
    private Socket threadedSocket;
    private String rootPath;
    private String logPath;
    private String uploadPath;
    private Thread thread;
    private static int requestNo = 0;
    private static int PORT;
    private static final String HTML_INTRO = "<html>\n" +
            "<head>\n" +
            "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\">\n" +
            "</head>\n" +
            "<body>\n";
    private static final String ERROR_MSG = "<h1> 404: Page not found </h1>\n";
    private static final String HTML_END = "</body>\n</html>";

    public ServerThreads(Socket socket, String root, String log, String uplaod, int port) {
        this.threadedSocket = socket;
        this.rootPath = root;
        this.logPath = log;
        this.uploadPath = uplaod;
        this.PORT = port;
        this.thread = new Thread(this);
        thread.start();
    }

    @Override
    public void run() {

        // creating buffered reader
        BufferedReader bufferedReader = null;
        try {
            bufferedReader = new BufferedReader(new InputStreamReader(threadedSocket.getInputStream()));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Input stream creation error!");
        }

        // reading http request
        String httpRequestInput = null;
        try {
             httpRequestInput = bufferedReader.readLine();
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Input stream reading error!");
        }

        // checking and handling GET requests
        if(httpRequestInput == null || httpRequestInput.startsWith("GET")){

            // handling null requests first
            if(httpRequestInput == null){
                try {
                    bufferedReader.close();
                    threadedSocket.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Null HTTP request handling error");
                } finally {
                    return;
                }
            }

            // handling GET request
            PrintWriter printWriter = null, fileWriter=null;
            try {
                printWriter = new PrintWriter(threadedSocket.getOutputStream());
                fileWriter = new PrintWriter(logPath + "\\Log " + (++requestNo) + ".txt");
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("Print writer stream creation error!");
            }

            // printing valid HTTP request on the server console
            System.out.println("HTTP request received from the client ...");
            System.out.println(">>> " + httpRequestInput);

            // printing request log into the log file
            fileWriter.println("HTTP request received from the client ...");
            fileWriter.println(">>> " + httpRequestInput + "\n");

            String extractedPath = "";
            String[] inputs = httpRequestInput.split("/");

            // ignoring the request prefix at the 0th index and the version 1.1 at the last index
            for(int i=1; i<inputs.length-1; i++){
                // handling the last entry
                if(i==inputs.length-2){
                    extractedPath += inputs[i].replace(" HTTP", "");
                } else{
                    extractedPath += inputs[i] + "\\";
                }
            }

            File file;
            File[] insideDirectory;

            // file content creation
            if(extractedPath.equals("")){
                file = new File(rootPath);
//                System.out.println(extractedPath);

            } else {
                // space representation handling
                extractedPath = extractedPath.replace("%20", " ") + "\\";
                file = new File(rootPath + "\\" + extractedPath);
//                System.out.println(extractedPath);
            }


            // start building the response
            StringBuilder stringBuilder = new StringBuilder();

            if(file.exists()){
                if(file.isDirectory()){
                    insideDirectory = file.listFiles();
                    stringBuilder.append(HTML_INTRO);

                    for(int i=0; i<insideDirectory.length; i++){

                        // showing directory contents
                        if(insideDirectory[i].isDirectory()){
                            stringBuilder.append("<b><i><a href=\"http://localhost:" + PORT + "/" +
                                    extractedPath.replace("\\", "/") + insideDirectory[i].getName() +
                                    "\"> " + insideDirectory[i].getName() + " </a></i></b><br>\n");

                        } else if(insideDirectory[i].isFile()){
                            stringBuilder.append("<a href=\"http://localhost:" + PORT + "/" +
                                    extractedPath.replace("\\", "/") + insideDirectory[i].getName() +
                                    "\"> " + insideDirectory[i].getName() + " </a><br>\n");
                        }
                    }
                    stringBuilder.append(HTML_END);
                }
            } else{
                // request content doesn't exist or not found
                stringBuilder.append(HTML_INTRO);
                stringBuilder.append(ERROR_MSG);
                stringBuilder.append(HTML_END);
            }

            System.out.println("HTTP response sent to the client ...");
            fileWriter.println("HTTP response sent to the client ...");
            String httpResponseOutput = "";

            if(httpRequestInput.length()>0){
                if(httpRequestInput.startsWith("GET")){
                    if(file.exists() && file.isDirectory()){
                        httpResponseOutput += "HTTP/1.1 200 OK\r\nServer: Java HTTP Server: 1.0\r\nDate: " + new Date() + "\r\n" +
                                "Content-Type: text/html\r\nContent-Length: " + stringBuilder.toString().length() + "\r\n";

                        // log file doesn't contain whole response message body
                        System.out.println(">>> " + httpResponseOutput);
                        fileWriter.println(">>> " + httpResponseOutput);

                        printWriter.write(httpResponseOutput);
                        printWriter.write("\r\n");
                        // actual message body to be displayed
                        printWriter.write(stringBuilder.toString());
                        printWriter.flush();
                    } else if(file.exists() && file.isFile()){
//                        System.out.println("file name " + file.getName());

                        if(file.getName().endsWith("txt")){
                            httpResponseOutput += "HTTP/1.1 200 OK\r\nServer: Java HTTP Server: 1.0\r\nDate: " + new Date() +
                                    "\r\nContent-Type: text/html\r\nContent-Length: " + file.length() + "\r\n";
                        } else if(file.getName().endsWith("jpg") || file.getName().endsWith("png") || file.getName().endsWith("jpeg")){
                            httpResponseOutput += "HTTP/1.1 200 OK\r\nServer: Java HTTP Server: 1:0\r\nDate: " + new Date() +
                                    "\r\nContent-Type: image/jpg\r\nContent-Length: " + file.length() + "\r\n";
                        } else{
                            httpResponseOutput += "HTTP/1.1 200 OK\r\nServer: Java HTTP Server: 1.0\r\nDate: " + new Date() + "\r\n" +
                                    "Content-Type: application/x-force-download\r\nContent-Length: " + file.length() + "\r\n";
                        }

                        System.out.println(">>> " + httpResponseOutput);
                        fileWriter.println(">>> " + httpResponseOutput);

                        printWriter.write(httpResponseOutput);
                        printWriter.write("\r\n");
                        printWriter.flush();

                        // binary style byte by byte data sending in chunk
                        int len;
                        byte[] buffer = new byte[2048];

                        try {
                            OutputStream out = threadedSocket.getOutputStream();
                            BufferedInputStream in = new BufferedInputStream(new FileInputStream(file));

                            while((len = in.read(buffer))>0){
                                out.write(buffer, 0, len);
                                out.flush();
                            }

                            in.close();
                            out.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                            System.out.println("Output stream generation error");

                        }
                    } else if(!file.exists()){
                        httpResponseOutput += "HTTP/1.1 404 NOT FOUND\r\nServer: Java HTTP Server: 1.0\r\nDate: "
                                + new Date() + "\r\nContent-Type: text/html\r\nContent-Length: " +
                                stringBuilder.toString().length() + "\r\n";

                        System.out.println(">>> " + httpResponseOutput);
                        fileWriter.println(">>> " + httpResponseOutput);

                        printWriter.write(httpResponseOutput);
                        printWriter.write("\r\n");
                        printWriter.write(stringBuilder.toString());
                        printWriter.flush();
                    }
                }
            }

            try {
                bufferedReader.close();
            } catch (IOException e) {
                e.printStackTrace();
                System.out.println("Buffered reader closing error");
            }
            printWriter.close();
            fileWriter.close();
        }

        else if(httpRequestInput.startsWith("UPLOAD")){
            PrintWriter printWriter = null;
            String filename = httpRequestInput.split(" ")[1];
            if(filename.endsWith("txt") || filename.endsWith("jpg") || filename.endsWith("png") || filename.endsWith("jpeg") || filename.endsWith("mp4")){
                try {
                    printWriter = new PrintWriter(threadedSocket.getOutputStream());
                    printWriter.write("valid" + "\r\n");
                    printWriter.flush();
                    System.out.println(">>> Given file name is valid");
//                    printWriter.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Server print writer creation error");
                }

                int len;
                byte[] buffer = new byte[2048];

                try {
                    // 7 for ignoring the UPLOAD part
                    FileOutputStream fileOutputStream = new FileOutputStream(new File(
                            uploadPath + "\\" + httpRequestInput.substring(7)));
                    InputStream in = threadedSocket.getInputStream();

                    while((len = in.read(buffer))>0){
                        fileOutputStream.write(buffer, 0, len);
                    }

                    in.close();
                    fileOutputStream.close();
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                    System.out.println("Uploaded file receive stream error");
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Input stream creation error");
                }

            } else{
                try {
                    printWriter = new PrintWriter(threadedSocket.getOutputStream());
                    printWriter.write("invalid" + "\r\n");
                    printWriter.flush();
                    System.out.println(">>> Given file name is invalid");
                    printWriter.close();
                    bufferedReader.close();

                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Server print writer creation error");
                }
            }
        }
        try {
            bufferedReader.close();
            threadedSocket.close();
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Buffered reader or socket closing error");
        }
        return;
    }
}
