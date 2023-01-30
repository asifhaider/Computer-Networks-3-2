package threads;

import java.io.*;
import java.net.Socket;

public class ClientThreads implements Runnable {
    private Socket clientSocket;
    private int port;
    private File inputFile;
    private Thread thread;
    private String locationPath;
    public ClientThreads(String filename, String location, int port) {
        this.locationPath = location;
        this.port = port;
        this.inputFile = new File(locationPath + "\\" + filename);
        thread = new Thread(this);
        thread.start();
    }

    @Override
    public void run() {
        try {
            clientSocket = new Socket("localhost", this.port);
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Client socket creation error");
        }

        if(!inputFile.exists()){
            System.out.println(">>> Given file doesn't exist in the directory");
            return;
        }
        // upload request to web server
        PrintWriter printWriter = null;

        try {
            printWriter = new PrintWriter(clientSocket.getOutputStream());
            printWriter.write("UPLOAD " + inputFile.getName() + "\r\n");
            printWriter.flush();
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Client print writer creation error");
        }

        BufferedReader bufferedReader = null;
        try {
            bufferedReader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Input stream creation error!");
        }

        String validity = null;
        try {
            validity = bufferedReader.readLine();
            if(validity.equalsIgnoreCase("invalid")){
                System.out.println(">>> Given file name is invalid");
                bufferedReader.close();
                printWriter.close();
//                clientSocket.close();
                return;
            } else {
                int len;
                byte[] buffer = new byte[512];

                try {
                    OutputStream out = clientSocket.getOutputStream();
                    BufferedInputStream in = new BufferedInputStream(new FileInputStream(inputFile));

                    while((len=in.read(buffer))>0){
                        out.write(buffer, 0, len);
                        out.flush();
                    }

                    in.close();
                    out.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Output stream error");
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Input stream reading error!");
        }

        printWriter.close();
        try {
            clientSocket.close();
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Client socket closing error");
        }
        return;
    }
}
