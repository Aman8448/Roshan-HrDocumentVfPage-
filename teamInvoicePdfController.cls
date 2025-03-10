public class teamInvoicePdfController {
    public Applicant__c teamObj{get;set;}
    Public Document docObj {get;set;}
	public String recordId {get;set;}
    public boolean showeInvoiceError {get;set;}
    public String selectedOption { get; set; }
    public List<SelectOption> options { get; set; }
    public List<String> links { get; set; }
    public String buttonType {get;set;}
    Public String currentDate {get;set;}
    Public String jobEffectiveDate {get;set;}
    public String Option { get; set; } 
    public String footerImage {get; set;}
    
    public teamInvoicePdfController(ApexPages.StandardController stdController){
        Date todayDate = Date.Today();
        Date myDate = date.newInstance(todayDate.year(), todayDate.month(),todayDate.Day());
	    currentDate = String.valueOf(myDate.format());
        recordId = ApexPages.CurrentPage().getparameters().get('Id');
        buttonType =System.currentPageReference().getParameters().get('buttonType');
        System.debug('team  RecordId---'+recordId);
        System.debug('buttonType ---'+buttonType);
        
        
        teamObj = [SELECT id, Name, Job_Title__c, Job_Title_Arabic__c, Job_effective_date__c, Arabic_Name__c,Nationality_Arabic__c, 
                   ID_Number__c, Nationality_Iqama__c, Basic_salary__c, Accomodation__c,Currency__c,  
                   Transportation__c, Full_Package__c FROM Applicant__c WHERE Id=:recordId];
        System.debug('teamObj-----' + teamObj);
        
        Date jobDate = teamObj.Job_effective_date__c;
         Date convertDate = date.newInstance(jobDate.year(), jobDate.month(),jobDate.Day());
	    jobEffectiveDate = String.valueOf(convertDate.format());
        
        docObj = [SELECT id,Name,DeveloperName,Body,ContentType FROM Document WHERE DeveloperName ='Logo_jpg'];
        System.debug('docObj----' + docObj);
        
        footerImage = EncodingUtil.Base64Encode(docObj.body);
        System.debug('footerImage----' + footerImage);
        
        /*
         if (selectedOption == 'Page1') {
             Option = 'Page1';
           // pageUrl = 'https://ka--fullcopy--c.sandbox.vf.force.com/apex/Salary_Certificate?Id=' + recordId + '&buttonType=' + buttonType;
        } else if (selectedOption == 'Page2') {
             Option = 'Page2';
           // pageUrl = '/apex/Salary_Certificate?Id=' + recordId + '&buttonType=' + buttonType + '&page=Page2';
        } else if (selectedOption == 'Page3') {
             Option = 'Page3';
           // pageUrl = '/apex/Salary_Certificate?Id=' + recordId + '&buttonType=' + buttonType + '&page=Page3';
        }
        
*/
       
        if (selectedOption == 'Page1' || selectedOption == 'Page2' || selectedOption == 'Page3')
        {
            showeInvoiceError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not permitted to use that on this record'));
           
        } 
        else{
             showeInvoiceError = false;
        }
        
    }

    public Pagereference backButtonMethod(){
        Pagereference newpage = new pageReference('/' +recordId );
        return newpage.setRedirect(true);
    }
    
    public Pagereference attachmentMethod(){
        System.debug('selectedOption---' + selectedOption);
         PageReference PDf ;
         if(selectedOption == 'Page1'){
             System.debug('enter page1');
         PDf =  Page.Salary_Certificate;
        } else if(selectedOption == 'Page2'){
             System.debug('enter page2');
         PDf =   Page.Salary_Certificate;
        }else if(selectedOption == 'Page3'){
             System.debug('enter page1');
         PDf =  Page.Salary_Certificate;
        }
       // PDF = page.Salary_Certificate;
        PDf.getParameters().put('id',recordId);
        PDf.getParameters().put('buttonType',buttonType);//set the button type
        PDf.getParameters().put('stopXLMSave','true');//set the button type
        PDf.setRedirect(true);
        Blob blobValue = PDf.getContent();
        String subject = 'Document';
        System.debug('blobValue---' + blobValue);
        ContentVersion cv = new ContentVersion();
        cv.Title = subject+'.html';
        cv.PathOnClient = subject;
        cv.VersionData = blobValue;
        cv.IsMajorVersion = true;
        Insert cv;
        
         GeneratePDFFileFromHTML(cv.Title,subject,recordId);
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = recordId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        System.debug('recordId---' + recordId);
        
       // Pagereference newpage = new pageReference('https://ka--fullcopy.sandbox.lightning.force.com/lightning/r/Applicant__c/a1b0Y000000KkhYQAS/view' );
        Pagereference newpage = new pageReference('/lightning/r/Applicant__c/' +recordId +'/view' );
        return newpage.setRedirect(true);
        
        
    }
    
      @future(callout=true)
    public static void GeneratePDFFileFromHTML(String fileName,String destinationFile,Id recordId)
    {
        Map<string, Object> parameters = new Map<string, Object>();
        //string footer = '<div style=\'width:100%;text-align:right\'>Khoshaim &amp; Associates is the law office of Zeyad S. Khoshaim, a sole proprietorship licensed to practice in Saudi Arabia under Ministry of Justice license number (29/90), registered with the Chamber of Commerce under registration number (253904), and operates from the 17th Floor, Tower B, Olaya Towers, Olaya District, Post Office Box 230667, Riyadh, Post Code 11321, Kingdom of Saudi Arabia.<span style=\'font-size:10px;margin-right:20px\'>Page <span class=\'pageNumber\'></span> of <span class=\'totalPages\'></span>.</span></div>';
        ContentVersion cv = [select Title, VersionData from ContentVersion where Title = :fileName order by createddate desc limit 1];
        System.debug('cv===' + cv);
        String body = cv.VersionData.toString();
        system.debug('--body--'+body);
        
        parameters.put('html', body);
        parameters.put('name', destinationFile);
        parameters.put('margins', '0px 0px 5px 0px');
        parameters.put('paperSize', 'Letter');
        parameters.put('orientation', 'Portrait');
        parameters.put('printBackground', true);
        parameters.put('asyncy', false);
        parameters.put('header', '');
        parameters.put('footer', '<span style=\'font-size:6px; color: red;\'><span style=\'padding-left: 20px; color: red;\' class=\'about\'>www.khoshaim.com</span> <span style=\'text-align: right; padding-left: 485px; \' class=\'pageNumber\'></span>/<span class=\'totalPages\'></span></span>');
        // parameters.put('imagesString', '20;80;0-;https://ka--fullcopy--c.documentforce.com/servlet/servlet.ImageServer?id=0150Q000000PqaH&oid=00D0Q0000000erT&lastMod=1650995433000;www.pdf.co;200;200');
        string jsonPayload = Json.serialize(parameters);
        System.debug('jsonPayload----' + jsonPayload);
        string url = 'https://api.pdf.co/v1/pdf/convert/from/html';
        HttpRequest req1 = new HttpRequest();
        req1.setBody(jsonPayload);
        req1.setHeader('x-api-key', label.PDFcoKey);
        req1.setHeader('Content-Type', 'application/json');
        req1.setEndpoint(url);
        req1.setMethod('POST');
        req1.setTimeout(60000);
        Http http = new Http();
        HTTPResponse res1 = http.send(req1);
        System.debug('==res1=='+res1.getBody());
        if(res1.getStatusCode() == 200){
            Map<String, Object> deserializedBody =  (Map<String, Object>)JSON.deserializeUntyped(res1.getBody());
            Boolean isError = Boolean.ValueOf(deserializedBody.get('error'));
            if(isError == false)
            {
                System.debug('==deserializedBody=='+deserializedBody);
                System.debug('==deserializedBody=get(url)='+(String)deserializedBody.get('url'));
                String urlVal = (String)deserializedBody.get('url');
                fetchDataAndCreatePDF(urlVal, DestinationFile,recordId);
                
            }
        }
        else
        {
            System.debug('Success Response ' + res1.getBody());
            System.Debug(' Status ' + res1.getStatus());
            System.Debug(' Status Code' + res1.getStatusCode());
            System.Debug(' Status String' + res1.toString());
        }
    }
    
     public static void fetchDataAndCreatePDF(string sourceURL, string DestinatnFile, string recordId)
    {
        system.debug('--sourceURL--'+sourceURL);
        system.debug('--DestinatnFile--'+DestinatnFile);
        system.debug('--recordId--'+recordId);
        
        String API_KEY = label.PDFcoKey;       
        string SourceFileUrl = sourceURL;
        string Pages = '';
        string Password = '';
        String DestinationFile = DestinatnFile;
        string Type = 'annotation';
        Integer X = 20;
        Integer Y = 709;
        string Text='' ;
        string Text2='' ;
        string Text3='' ;
        string secondPgLastPara1stline='' ;
        string secondPgLastPara2stline=''; 
        string secondPgLastPara3stline=''; 
        string secondPgLastPara4stline='' ;
        //string secondPgLastPara5stline 
        string secondPgLastPara5stline='' ;
        string secondPgLastPara6stline='' ;
        string secondPgLastPara7stline='' ;
        string secondPgLastMidPara2stline='' ;
        string secondPgLastMidPara5stline='' ;
     
     
             Text = 'K&A  is  a trademark licensed to  the  management\\nconsulting   Dubai   branch   with   registration   no.\\n1413422  of  Khoshaim & Associates (K&A)  Ltd, a\\ncompany incorporated in Abu Dhabi Global Market. \\n  \\nRiyadh | Jeddah | Abu Dhabi';
             Text2 = '';
             Text3 = 'هي علامة تجارية مرخصة لفرع الاستشارات الإدارية في إمارة دبي لشركة خشيم K&A\\nومشاركوه )كيه اند ايه( ال تي دي،   مقيدة بالرقم 1413422 ، وهي شركة مسجلة لدى\\n                                                                           .سوق أبوظبي العالمي\\n \\n                                                                           الرياض| جدة| أبوظبي';
             secondPgLastPara1stline = '';
             secondPgLastPara2stline = '';
             secondPgLastPara3stline = '';
             secondPgLastPara4stline = '';
             secondPgLastPara5stline = '';
             secondPgLastPara6stline = '';
             secondPgLastPara7stline = '';
            secondPgLastMidPara2stline = '';
            secondPgLastMidPara5stline = '';

        string jsonPayload = '{ "inline": true, "name": "result.pdf", "url": "'+sourceURL+'","annotations": [ { "text": "'+Text+'", "x": 20, "y": 709,"size": 7,  "color": "#aaa"},'
                                    +'{ "text": "'+Text2+'", "x": 412, "y": 709, "size": 5,  "color": "#aaa"}, '
                                    +'{ "text": "'+Text3+'", "x": 285, "y": 709, "size": 5,  "color": "#aaa"},'

                                    +'{ "text": "'+secondPgLastPara1stline+'", "x": 444, "y": 703,"size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},' 
                                    +'{ "text": "'+secondPgLastPara2stline+'", "x": 429, "y": 713,"size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastPara3stline+'", "x": 439, "y": 722, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastPara4stline+'", "x": 442, "y": 731,"size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastPara5stline+'", "x": 429, "y": 740, "size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastPara6stline+'", "x": 446, "y": 749,"size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastPara7stline+'", "x": 552, "y": 758,"size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'

                                    +'{ "text": "", "x": 375, "y": 703, "size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},' 
                                    +'{ "text": "'+ secondPgLastMidPara2stline+'", "x": 332, "y": 722,"size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 366, "y": 731, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 370, "y": 740, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "'+ secondPgLastMidPara5stline+'", "x": 301, "y": 749,  "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 328, "y": 758,"size": 7,"color": "#aaa", "fontName": "Arabic Typesetting"},'

                                    +'{ "text": "", "x": 242, "y": 703, "size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},' 
                                    +'{ "text": "", "x": 155, "y": 722, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 190, "y": 731, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 194, "y": 740, "size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
                                    +'{ "text": "", "x": 169, "y": 749, "size": 7,  "color": "#aaa", "fontName": "Arabic Typesetting"},'
          							+'{ "text": "", "x": 183, "y": 758, "size": 7, "color": "#aaa", "fontName": "Arabic Typesetting"}],'
                                    +' "images": [ { "url": "https://ka--c.documentforce.com/servlet/servlet.ImageServer?id=0151n000003v5Gz&oid=00D0Y000002k92Z&lastMod=1657023375000", "x": 450, "y": 685, "width": 150, "height": 100 }]}';
       System.debug('jsonPayload-----' + jsonPayload);
        try
        {
    
            String jsonStr= '{ "inline": true, "name": "result.pdf", "url": "'+sourceURL+'","annotations": [{"x": 20, "y": 709}],'
                			+' "images": [ { "url": "https://ka--c.documentforce.com/servlet/servlet.ImageServer?id=0151n000003v5Gz&oid=00D0Y000002k92Z&lastMod=1657023375000", "x": 450, "y": 685, "width": 200, "height": 80, "pages": "0,1,2-" }]}';

            string url = 'https://api.pdf.co/v1/pdf/edit/add';
            HttpRequest req = new HttpRequest();
            req.setBody(jsonPayload);
            req.setHeader('x-api-key', API_KEY);
            req.setHeader('Content-Type', 'application/json');
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setTimeout(60000);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if(res.getStatusCode() == 200) 
            {
                System.Debug('res ' + res);
                Map<String, Object> deserializedBody =  (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String urlVal = (String)deserializedBody.get('url');
                //@downloadPDFAndStore(urlVal, DestinationFile, recordId);
                compressPDFDocument(urlVal, DestinationFile, recordId);
            }
            else
            {
                System.debug('Success Response ' + res.getBody());
                System.Debug(' Status ' + res.getStatus());
                System.Debug(' Status Code' + res.getStatusCode());
                System.Debug(' Status String' + res.toString());
            }
           
        }
        catch(Exception ex)
        {
            String errorBody = 'Message: ' + ex.getMessage() + ' -- Cause: ' + ex.getCause() + ' -- Stacktrace: ' + ex.getStackTraceString();
            System.Debug(errorBody);
        }
    
}
    
     public static void compressPDFDocument(string urlVal, String DestinationFile, string recordId){        
        try
        {
            // Create HTTP client instance
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            // Set API Key
            request.setHeader('x-api-key', label.PDFcoKey);
                        
            // If enabled, Runs processing asynchronously. Returns Use JobId that you may use with /job/check to check state of the processing (possible states: working, 
            Boolean async = false;
            
            // See documentation: https://apidocs.pdf.co
            // Create JSON payload
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('url', urlVal);
            gen.writeStringField('name', DestinationFile);
            gen.writeBooleanField('async', async);

            gen.writeEndObject();

            // Convert dictionary of params to JSON
            String jsonPayload = gen.getAsString();
            
            // URL of 'PDF Security' endpoint
            string url = 'https://api.pdf.co/v1/pdf/optimize';
            request.setEndpoint(url);            
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setMethod('POST');
            request.setBody(jsonPayload);
            // Execute request
            HttpResponse response =  http.send(request);                
            
            // Parse JSON response
            Map<String, Object> json = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            
            if(response.getStatusCode() == 200) 
            {
                if ((Boolean)json.get('error') == false)
                {
                    // Get URL of generated PDF file
                    String resultFileUrl =(String)json.get('url');
                    
                    // Download generated PDF file
                    downloadPDFAndStore(resultFileUrl, DestinationFile, recordId);
                    
                }
            }
            else
            {
                System.debug('Error Response ' + response.getBody());
                System.Debug(' Status ' + response.getStatus());
                System.Debug(' Status Code' + response.getStatusCode());
                System.Debug(' Response String' + response.toString());
            }
        }
        catch (Exception ex)
        {
            String errorBody = 'Message: ' + ex.getMessage() + ' -- Cause: ' + ex.getCause() + ' -- Stacktrace: ' + ex.getStackTraceString();
            System.Debug(errorBody);
        }
    }
 @TestVisible
    private static void downloadPDFAndStore(String extFileUrl, String DestinationFile, string recordId)
    {
        try
        {
            Http h = new Http(); 
            HttpRequest req = new HttpRequest(); 
            extFileUrl = extFileUrl.replace(' ', '%20'); 
            req.setEndpoint(extFileUrl);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/pdf'); 
            req.setCompressed(true);
            req.setTimeout(60000);

            //Now Send HTTP Request
            HttpResponse res  = h.send(req);
            if(res.getStatusCode() == 200)
            {
                System.Debug('fileContent'+ res.getBodyAsBlob());
                blob fileContent = res.getBodyAsBlob();
                //Added by ajay
                System.Debug('fileContent'+fileContent);

                string pdfContent = EncodingUtil.base64Encode(fileContent);
                System.Debug('pdfContent---'+pdfContent);

                ContentVersion conVer = new ContentVersion();
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
                conVer.PathOnClient = DestinationFile + '.pdf'; // The files name, extension is very important here which will help the file in preview.
                conVer.Title = DestinationFile; // Display name of the files
                conVer.VersionData = fileContent;
                insert conVer;
                
                
                Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                
                //Create ContentDocumentLink 
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = recordId;
                cdl.ContentDocumentId = conDocId;
                cdl.shareType = 'V';
                Insert cdl;
                System.Debug('Success');

               // }else{
                     //to get the PDF from the clear tax
                    // getXMlPdf(pdfContent,DestinationFile,recordId);
               // }

                
               
               
            }
            else
            {
                System.debug('Success Response ' + res.getBody());
                System.Debug(' Status ' + res.getStatus());
                System.Debug(' Status Code' + res.getStatusCode());
                System.Debug(' Status String' + res.toString());
            }
        }
        catch(Exception ex)
        {
            String errorBody = 'Message: ' + ex.getMessage() + ' -- Cause: ' + ex.getCause() + ' -- Stacktrace: ' + ex.getStackTraceString();
            System.Debug(errorBody);
        }
    }
    
}