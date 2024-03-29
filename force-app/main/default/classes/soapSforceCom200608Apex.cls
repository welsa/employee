public class soapSforceCom200608Apex {
// ABT 10-JUN-2016 - Commented Class 
/*
    public class AllowFieldTruncationHeader_element {
        public Boolean allowFieldTruncation;
        private String[] allowFieldTruncation_type_info = new String[]{'allowFieldTruncation','http://soap.sforce.com/2006/08/apex','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'allowFieldTruncation'};
        public AllowFieldTruncationHeader_element(){
        }
        public AllowFieldTruncationHeader_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode allowFieldTruncationNode = responseNode.getChildElement('allowFieldTruncation', 'http://soap.sforce.com/2006/08/apex');
            this.allowFieldTruncation = (allowFieldTruncationNode == null) ? null : Boolean.valueOf(allowFieldTruncationNode.getText());
            nodesParsed.add(allowFieldTruncationNode);
            //System.debug(this.allowFieldTruncation);          
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode allowFieldTruncationNode = outerNode.addChildElement('allowFieldTruncation', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.allowFieldTruncation != null){
                allowFieldTruncationNode.addTextNode(String.valueOf(this.allowFieldTruncation));
            }
        }
    }
    public class Apex {
        public String endpoint_x = 'https://na2.salesforce.com/services/Soap/s/31.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public soapSforceCom200608Apex.SessionHeader_element SessionHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.DebuggingHeader_element DebuggingHeader;
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.PackageVersionHeader_element PackageVersionHeader;
        private String PackageVersionHeader_hns = 'PackageVersionHeader=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.CallOptions_element CallOptions;
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.AllowFieldTruncationHeader_element AllowFieldTruncationHeader;
        private String AllowFieldTruncationHeader_hns = 'AllowFieldTruncationHeader=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.DisableFeedTrackingHeader_element DisableFeedTrackingHeader;
        private String DisableFeedTrackingHeader_hns = 'DisableFeedTrackingHeader=http://soap.sforce.com/2006/08/apex';
        public soapSforceCom200608Apex.DebuggingInfo_element DebuggingInfo;
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/08/apex';
        private String[] ns_map_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','soapSforceCom200608Apex'};
 
        public soapSforceCom200608Apex.ExecuteAnonymousResult executeAnonymous(String String_x) {
            soapSforceCom200608Apex.executeAnonymous_element request_x = new soapSforceCom200608Apex.executeAnonymous_element();
            soapSforceCom200608Apex.executeAnonymousResponse_element response_x;
            request_x.String_x = String_x;
            Map<String, soapSforceCom200608Apex.executeAnonymousResponse_element> response_map_x = new Map<String, soapSforceCom200608Apex.executeAnonymousResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                this,
                request_x,
                response_map_x,
                new String[]{endpoint_x,
                '',
                'http://soap.sforce.com/2006/08/apex',
                'executeAnonymous',
                'http://soap.sforce.com/2006/08/apex',
                'executeAnonymousResponse',
                'soapSforceCom200608Apex.executeAnonymousResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        
        private DOM.XmlNode populateDoc(DOM.Document doc){
            String env = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
            String xsd = 'http://www.w3.org/2001/XMLSchema';
            
            DOM.XmlNode envelope = doc.createRootElement('Envelope', env, 'env');
            envelope.setNamespace('xsd', xsd);
            envelope.setNamespace('xsi', xsi);
            DOM.XmlNode header = envelope.addChildElement('Header', env, '');
            AddHeader(header);
            //System.debug(doc.toXmlString());
            DOM.XmlNode body = envelope.addChildElement('Body', env, '');
            return body;
        }
 
        private void AddHeader(DOM.XmlNode header){
            if(this.SessionHeader != null){
                DOM.XmlNode SessionHeaderNode = header.addChildElement('SessionHeader', 'http://soap.sforce.com/2006/08/apex', '');
                SessionHeader.populateXmlNode(SessionHeaderNode);
            }
            if(this.DebuggingHeader != null){
                DOM.XmlNode DebuggingHeaderNode = header.addChildElement('DebuggingHeader', 'http://soap.sforce.com/2006/08/apex', '');
                DebuggingHeader.populateXmlNode(DebuggingHeaderNode);
            }
            if(this.PackageVersionHeader != null){
                DOM.XmlNode PackageVersionHeaderNode = header.addChildElement('PackageVersionHeader', 'http://soap.sforce.com/2006/08/apex', '');
                PackageVersionHeader.populateXmlNode(PackageVersionHeaderNode);
            }
            if(this.CallOptions != null){
                DOM.XmlNode CallOptionsNode = header.addChildElement('CallOptions', 'http://soap.sforce.com/2006/08/apex', '');
                CallOptions.populateXmlNode(CallOptionsNode);
            }
            if(this.AllowFieldTruncationHeader != null){
                DOM.XmlNode AllowFieldTruncationHeaderNode = header.addChildElement('AllowFieldTruncationHeader', 'http://soap.sforce.com/2006/08/apex', '');
                AllowFieldTruncationHeader.populateXmlNode(AllowFieldTruncationHeaderNode);
            }
            if(this.DisableFeedTrackingHeader != null){
                DOM.XmlNode DisableFeedTrackingHeaderNode = header.addChildElement('DisableFeedTrackingHeader', 'http://soap.sforce.com/2006/08/apex', '');
                DisableFeedTrackingHeader.populateXmlNode(DisableFeedTrackingHeaderNode);
            }
            if(this.DebuggingInfo != null){
                DOM.XmlNode DebuggingInfoNode = header.addChildElement('DebuggingInfo', 'http://soap.sforce.com/2006/08/apex', '');
                DebuggingInfo.populateXmlNode(DebuggingInfoNode);
            }
        }
 
        public soapSforceCom200608Apex.ExecuteAnonymousResult executeAnonymous_Http(String String_x) {
            DOM.Document doc = new DOM.Document();
            DOM.XmlNode body = populateDoc(doc);
            DOM.XmlNode methodNode = body.addChildElement('executeAnonymous', 'http://soap.sforce.com/2006/08/apex', '');           
            soapSforceCom200608Apex.executeAnonymous_element request_x = new soapSforceCom200608Apex.executeAnonymous_element(String_x);
            request_x.populateXmlNode(methodNode);
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint_x);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            req.setHeader('SOAPAction', 'blank');
            req.setBodyDocument(doc);
            //System.debug(req.getBody());
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
            //System.debug(LoggingLevel.Error, res.getBody());
            //<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/08/apex" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            //<soapenv:Header><DebuggingInfo><debugLog>
            
            //System.debug(res.getBody());
            Dom.Document responseDoc = res.getBodyDocument();
            Dom.XmlNode rootNode = responseDoc.getRootElement();
            Dom.XmlNode bodyNode = rootNode.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
            Dom.XmlNode headerNode = rootNode.getChildElement('Header','http://schemas.xmlsoap.org/soap/envelope/');
            
            //System.debug(LoggingLevel.Error, headerNode.getChildElements()[0].getChildElements()[0].getText());
            
            DebuggingInfo_element debugHeader = new DebuggingInfo_element(headerNode.getChildElements()[0]);
            this.DebuggingInfo = debugHeader;
            
            //System.debug(LoggingLevel.Error, 'debugLog: <<' + debugHeader.debugLog  + '>>');
            
            //Dom.XmlNode debuggingInfoNode2 = headerNode.getChildElement('debugLog','http://soap.sforce.com/2006/08/apex');
            //Dom.XmlNode debuggingInfoNode2 = headerNode.getChildElements()[0];
            
            
            //System.debug(LoggingLevel.Error, 'debuggingInfoNode2: <<' + debuggingInfoNode2 + '>>');
            
            Dom.XmlNode executeAnonymousResponseNode = bodyNode.getChildElement('executeAnonymousResponse', 'http://soap.sforce.com/2006/08/apex');
                        
            soapSforceCom200608Apex.executeAnonymousResponse_element response_x = new soapSforceCom200608Apex.executeAnonymousResponse_element(executeAnonymousResponseNode);
            response_x.result.DebuggingInfo = debugHeader;
            return response_x.result;
        }
    }
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client','http://soap.sforce.com/2006/08/apex','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'client'};
        public CallOptions_element(){
        }
        public CallOptions_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode clientNode = responseNode.getChildElement('client', 'http://soap.sforce.com/2006/08/apex');
            this.client = (clientNode == null) ? null : clientNode.getText();
            nodesParsed.add(clientNode);
            //System.debug(this.client);            
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode clientNode = outerNode.addChildElement('client', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.client != null){
                clientNode.addTextNode(this.client);
            }
        }
    }
    public class DebuggingHeader_element {
        public soapSforceCom200608Apex.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories','http://soap.sforce.com/2006/08/apex','LogInfo','0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel','http://soap.sforce.com/2006/08/apex','LogType','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
        public DebuggingHeader_element(){
        }
        public DebuggingHeader_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            Dom.XmlNode[] categoriesChildren = responseNode.getChildElements();
            soapSforceCom200608Apex.LogInfo[] categoriesList = new List<soapSforceCom200608Apex.LogInfo>();
            if(categoriesChildren == null || categoriesChildren.size() == 0){
                this.categories = null;
            } else{
                for(DOM.XmlNode childNode : categoriesChildren){
                    if(childNode.GetName() == 'categories'){
                        soapSforceCom200608Apex.LogInfo Obj = new soapSforceCom200608Apex.LogInfo(childNode);
                        categoriesList.Add(Obj);
                        nodesParsed.add(childNode);
                    }
                }
                this.categories = categoriesList;
            }
            //System.debug(this.categories);            
            DOM.XmlNode debugLevelNode = responseNode.getChildElement('debugLevel', 'http://soap.sforce.com/2006/08/apex');
            this.debugLevel = (debugLevelNode == null) ? null : debugLevelNode.getText();
            nodesParsed.add(debugLevelNode);
            //System.debug(this.debugLevel);            
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            
            soapSforceCom200608Apex.LogInfo[] categoriesObj = this.categories;
            if(categoriesObj != null){
                for(soapSforceCom200608Apex.LogInfo element: categoriesObj){
                    Dom.XmlNode categoriesNode = outerNode.addChildElement('categories', 'http://soap.sforce.com/2006/08/apex', '');
                    element.populateXmlNode(categoriesNode);
                }
            }           
            Dom.XmlNode debugLevelNode = outerNode.addChildElement('debugLevel', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.debugLevel != null){
                debugLevelNode.addTextNode(this.debugLevel);
            }
        }
    }
    public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog','http://soap.sforce.com/2006/08/apex','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
        public DebuggingInfo_element(){
        }
        public DebuggingInfo_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode debugLogNode = responseNode.getChildElement('debugLog', 'http://soap.sforce.com/2006/08/apex');
            this.debugLog = (debugLogNode == null) ? null : debugLogNode.getText();
            nodesParsed.add(debugLogNode);
            //System.debug(this.debugLog);          
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode debugLogNode = outerNode.addChildElement('debugLog', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.debugLog != null){
                debugLogNode.addTextNode(this.debugLog);
            }
        }
    }
    public class DisableFeedTrackingHeader_element {
        public Boolean disableFeedTracking;
        private String[] disableFeedTracking_type_info = new String[]{'disableFeedTracking','http://soap.sforce.com/2006/08/apex','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'disableFeedTracking'};
        public DisableFeedTrackingHeader_element(){
        }
        public DisableFeedTrackingHeader_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode disableFeedTrackingNode = responseNode.getChildElement('disableFeedTracking', 'http://soap.sforce.com/2006/08/apex');
            this.disableFeedTracking = (disableFeedTrackingNode == null) ? null : Boolean.valueOf(disableFeedTrackingNode.getText());
            nodesParsed.add(disableFeedTrackingNode);
            //System.debug(this.disableFeedTracking);           
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode disableFeedTrackingNode = outerNode.addChildElement('disableFeedTracking', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.disableFeedTracking != null){
                disableFeedTrackingNode.addTextNode(String.valueOf(this.disableFeedTracking));
            }
        }
    }
    public class executeAnonymous_element {
        public String String_x;
        private String[] String_x_type_info = new String[]{'String','http://soap.sforce.com/2006/08/apex','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'String_x'};
        public executeAnonymous_element(){
        }
        public executeAnonymous_element(String String_x){
            this.String_x = String_x;
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            
            //System.assertEquals('executeAnonymous', outerNode.getName());
            Dom.XmlNode String_xNode = outerNode.addChildElement('String', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.String_x != null){
                String_xNode.addTextNode(this.String_x);
            }
        }
    }
    public class executeAnonymousResponse_element {
        public soapSforceCom200608Apex.ExecuteAnonymousResult result;
        private String[] result_type_info = new String[]{'result','http://soap.sforce.com/2006/08/apex','ExecuteAnonymousResult','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'result'};
        public executeAnonymousResponse_element(){
        }
        public executeAnonymousResponse_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            //System.assertEquals('executeAnonymousResponse', responseNode.getName());
            DOM.XmlNode resultNode = responseNode.getChildElement('result', 'http://soap.sforce.com/2006/08/apex');
            if(resultNode == null){
                this.result = null;
            } else{
                soapSforceCom200608Apex.ExecuteAnonymousResult resultObj = new soapSforceCom200608Apex.ExecuteAnonymousResult(resultNode);
                nodesParsed.add(resultNode);
                this.result = resultObj;
            }
            //System.debug(this.result);            
        }
    }
    public class ExecuteAnonymousResult {
        public Integer column;
        public String compileProblem;
        public Boolean compiled;
        public String exceptionMessage;
        public String exceptionStackTrace;
        public Integer line;
        public Boolean success;
        
        // Manually parsed from the SOAP response headers
        public soapSforceCom200608Apex.DebuggingInfo_element DebuggingInfo;
        
        private String[] column_type_info = new String[]{'column','http://soap.sforce.com/2006/08/apex','int','1','1','false'};
        private String[] compileProblem_type_info = new String[]{'compileProblem','http://soap.sforce.com/2006/08/apex','string','1','1','true'};
        private String[] compiled_type_info = new String[]{'compiled','http://soap.sforce.com/2006/08/apex','boolean','1','1','false'};
        private String[] exceptionMessage_type_info = new String[]{'exceptionMessage','http://soap.sforce.com/2006/08/apex','string','1','1','true'};
        private String[] exceptionStackTrace_type_info = new String[]{'exceptionStackTrace','http://soap.sforce.com/2006/08/apex','string','1','1','true'};
        private String[] line_type_info = new String[]{'line','http://soap.sforce.com/2006/08/apex','int','1','1','false'};
        private String[] success_type_info = new String[]{'success','http://soap.sforce.com/2006/08/apex','boolean','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'column','compileProblem','compiled','exceptionMessage','exceptionStackTrace','line','success'};
        public ExecuteAnonymousResult(){
        }
        public ExecuteAnonymousResult(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode columnNode = responseNode.getChildElement('column', 'http://soap.sforce.com/2006/08/apex');
            this.column = (columnNode == null) ? null : Integer.valueOf(columnNode.getText());
            nodesParsed.add(columnNode);
            //System.debug(this.column);            
            DOM.XmlNode compileProblemNode = responseNode.getChildElement('compileProblem', 'http://soap.sforce.com/2006/08/apex');
            this.compileProblem = (compileProblemNode == null || compileProblemNode.getAttributeValue('nil', 'http://www.w3.org/2001/XMLSchema-instance') == 'true') ? null : compileProblemNode.getText();
            nodesParsed.add(compileProblemNode);
            //System.debug(this.compileProblem);            
            DOM.XmlNode compiledNode = responseNode.getChildElement('compiled', 'http://soap.sforce.com/2006/08/apex');
            this.compiled = (compiledNode == null) ? null : Boolean.valueOf(compiledNode.getText());
            nodesParsed.add(compiledNode);
            //System.debug(this.compiled);          
            DOM.XmlNode exceptionMessageNode = responseNode.getChildElement('exceptionMessage', 'http://soap.sforce.com/2006/08/apex');
            this.exceptionMessage = (exceptionMessageNode == null || exceptionMessageNode.getAttributeValue('nil', 'http://www.w3.org/2001/XMLSchema-instance') == 'true') ? null : exceptionMessageNode.getText();
            nodesParsed.add(exceptionMessageNode);
            //System.debug(this.exceptionMessage);          
            DOM.XmlNode exceptionStackTraceNode = responseNode.getChildElement('exceptionStackTrace', 'http://soap.sforce.com/2006/08/apex');
            this.exceptionStackTrace = (exceptionStackTraceNode == null || exceptionStackTraceNode.getAttributeValue('nil', 'http://www.w3.org/2001/XMLSchema-instance') == 'true') ? null : exceptionStackTraceNode.getText();
            nodesParsed.add(exceptionStackTraceNode);
            //System.debug(this.exceptionStackTrace);           
            DOM.XmlNode lineNode = responseNode.getChildElement('line', 'http://soap.sforce.com/2006/08/apex');
            this.line = (lineNode == null) ? null : Integer.valueOf(lineNode.getText());
            nodesParsed.add(lineNode);
            //System.debug(this.line);          
            DOM.XmlNode successNode = responseNode.getChildElement('success', 'http://soap.sforce.com/2006/08/apex');
            this.success = (successNode == null) ? null : Boolean.valueOf(successNode.getText());
            nodesParsed.add(successNode);
            //System.debug(this.success);           
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode columnNode = outerNode.addChildElement('column', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.column != null){
                columnNode.addTextNode(String.valueOf(this.column));
            }
            Dom.XmlNode compileProblemNode = outerNode.addChildElement('compileProblem', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.compileProblem != null){
                compileProblemNode.addTextNode(this.compileProblem);
            }
            Dom.XmlNode compiledNode = outerNode.addChildElement('compiled', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.compiled != null){
                compiledNode.addTextNode(String.valueOf(this.compiled));
            }
            Dom.XmlNode exceptionMessageNode = outerNode.addChildElement('exceptionMessage', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.exceptionMessage != null){
                exceptionMessageNode.addTextNode(this.exceptionMessage);
            }
            Dom.XmlNode exceptionStackTraceNode = outerNode.addChildElement('exceptionStackTrace', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.exceptionStackTrace != null){
                exceptionStackTraceNode.addTextNode(this.exceptionStackTrace);
            }
            Dom.XmlNode lineNode = outerNode.addChildElement('line', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.line != null){
                lineNode.addTextNode(String.valueOf(this.line));
            }
            Dom.XmlNode successNode = outerNode.addChildElement('success', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.success != null){
                successNode.addTextNode(String.valueOf(this.success));
            }
        }
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category','http://soap.sforce.com/2006/08/apex','LogCategory','1','1','false'};
        private String[] level_type_info = new String[]{'level','http://soap.sforce.com/2006/08/apex','LogCategoryLevel','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
        public LogInfo(){
        }
        public LogInfo(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode categoryNode = responseNode.getChildElement('category', 'http://soap.sforce.com/2006/08/apex');
            this.category = (categoryNode == null) ? null : categoryNode.getText();
            nodesParsed.add(categoryNode);
            //System.debug(this.category);          
            DOM.XmlNode levelNode = responseNode.getChildElement('level', 'http://soap.sforce.com/2006/08/apex');
            this.level = (levelNode == null) ? null : levelNode.getText();
            nodesParsed.add(levelNode);
            //System.debug(this.level);         
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode categoryNode = outerNode.addChildElement('category', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.category != null){
                categoryNode.addTextNode(this.category);
            }
            Dom.XmlNode levelNode = outerNode.addChildElement('level', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.level != null){
                levelNode.addTextNode(this.level);
            }
        }
    }
    public class PackageVersion {
        public Integer majorNumber;
        public Integer minorNumber;
        public String namespace;
        private String[] majorNumber_type_info = new String[]{'majorNumber','http://soap.sforce.com/2006/08/apex','int','1','1','false'};
        private String[] minorNumber_type_info = new String[]{'minorNumber','http://soap.sforce.com/2006/08/apex','int','1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace','http://soap.sforce.com/2006/08/apex','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
        public PackageVersion(){
        }
        public PackageVersion(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode majorNumberNode = responseNode.getChildElement('majorNumber', 'http://soap.sforce.com/2006/08/apex');
            this.majorNumber = (majorNumberNode == null) ? null : Integer.valueOf(majorNumberNode.getText());
            nodesParsed.add(majorNumberNode);
            //System.debug(this.majorNumber);           
            DOM.XmlNode minorNumberNode = responseNode.getChildElement('minorNumber', 'http://soap.sforce.com/2006/08/apex');
            this.minorNumber = (minorNumberNode == null) ? null : Integer.valueOf(minorNumberNode.getText());
            nodesParsed.add(minorNumberNode);
            //System.debug(this.minorNumber);           
            DOM.XmlNode namespaceNode = responseNode.getChildElement('namespace', 'http://soap.sforce.com/2006/08/apex');
            this.namespace = (namespaceNode == null) ? null : namespaceNode.getText();
            nodesParsed.add(namespaceNode);
            //System.debug(this.namespace);         
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode majorNumberNode = outerNode.addChildElement('majorNumber', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.majorNumber != null){
                majorNumberNode.addTextNode(String.valueOf(this.majorNumber));
            }
            Dom.XmlNode minorNumberNode = outerNode.addChildElement('minorNumber', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.minorNumber != null){
                minorNumberNode.addTextNode(String.valueOf(this.minorNumber));
            }
            Dom.XmlNode namespaceNode = outerNode.addChildElement('namespace', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.namespace != null){
                namespaceNode.addTextNode(this.namespace);
            }
        }
    }
    public class PackageVersionHeader_element {
        public soapSforceCom200608Apex.PackageVersion[] packageVersions;
        private String[] packageVersions_type_info = new String[]{'packageVersions','http://soap.sforce.com/2006/08/apex','PackageVersion','0','-1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'packageVersions'};
        public PackageVersionHeader_element(){
        }
        public PackageVersionHeader_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            Dom.XmlNode[] packageVersionsChildren = responseNode.getChildElements();
            soapSforceCom200608Apex.PackageVersion[] packageVersionsList = new List<soapSforceCom200608Apex.PackageVersion>();
            if(packageVersionsChildren == null || packageVersionsChildren.size() == 0){
                this.packageVersions = null;
            } else{
                for(DOM.XmlNode childNode : packageVersionsChildren){
                    if(childNode.GetName() == 'packageVersions'){
                        soapSforceCom200608Apex.PackageVersion Obj = new soapSforceCom200608Apex.PackageVersion(childNode);
                        packageVersionsList.Add(Obj);
                        nodesParsed.add(childNode);
                    }
                }
                this.packageVersions = packageVersionsList;
            }
            //System.debug(this.packageVersions);           
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            
            soapSforceCom200608Apex.PackageVersion[] packageVersionsObj = this.packageVersions;
            if(packageVersionsObj != null){
                for(soapSforceCom200608Apex.PackageVersion element: packageVersionsObj){
                    Dom.XmlNode packageVersionsNode = outerNode.addChildElement('packageVersions', 'http://soap.sforce.com/2006/08/apex', '');
                    element.populateXmlNode(packageVersionsNode);
                }
            }           
        }
    }
    public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId','http://soap.sforce.com/2006/08/apex','string','1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://soap.sforce.com/2006/08/apex','true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
        public SessionHeader_element(){
        }
        public SessionHeader_element(DOM.XmlNode responseNode){
            Set<DOM.XmlNode> nodesParsed = new Set<DOM.XmlNode>();
            DOM.XmlNode sessionIdNode = responseNode.getChildElement('sessionId', 'http://soap.sforce.com/2006/08/apex');
            this.sessionId = (sessionIdNode == null) ? null : sessionIdNode.getText();
            nodesParsed.add(sessionIdNode);
            //System.debug(this.sessionId);         
        }
        public void populateXmlNode(Dom.XmlNode outerNode){
            Dom.XmlNode sessionIdNode = outerNode.addChildElement('sessionId', 'http://soap.sforce.com/2006/08/apex', '');
            if(this.sessionId != null){
                sessionIdNode.addTextNode(this.sessionId);
            }
        }
    }
 
    public static boolean evalBoolean(string evalApex) {
        string result = evalString(evalApex);
        return boolean.valueof(result);
    }    
   
    public static integer evalInteger(string evalApex) {
        string result = evalString(evalApex);
        return integer.valueof(result);
    }
    //public static double v;
    //@future(callout=true)
    public static double evalDouble(string evalApex) {
        string result = evalString(evalApex);
       //v = double.valueof(result);
       return double.valueof(result);
    }
    
    public static string evalString(string evalApex) {
        soapSforceCom200608Apex.Apex tooling = new soapSforceCom200608Apex.Apex();
        
        soapSforceCom200608Apex.SessionHeader_element header=new soapSforceCom200608Apex.SessionHeader_element();
        tooling.SessionHeader=header;
        
        header.sessionId=UserInfo.getSessionId();
        tooling.endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/s/31.0';
        
        tooling.DebuggingHeader = new soapSforceCom200608Apex.DebuggingHeader_element();
        tooling.DebuggingHeader.debugLevel = 'NONE'; //ExecutionLogType - https://www.salesforce.com/us/developer/docs/apexcode/Content/sforce_api_header_debuggingheader.htm
        
        tooling.DebuggingHeader.categories = new soapSforceCom200608Apex.LogInfo[0];
        tooling.DebuggingHeader.categories.add(new soapSforceCom200608Apex.LogInfo());
        tooling.DebuggingHeader.categories[0].category = 'Apex_code';
        tooling.DebuggingHeader.categories[0].level = 'ERROR';
        
        soapSforceCom200608Apex.ExecuteAnonymousResult result = tooling.executeAnonymous_http(evalApex);
        System.assert(result.success, result.compileProblem);
        
        string output = soapSforceCom200608Apex.extractFirstDebugLog(result.DebuggingInfo);
        
        return output;
    }
    
    private static string extractFirstDebugLog(soapSforceCom200608Apex.DebuggingInfo_element di) {
        //System.debug(LoggingLevel.Error, di);
        string debugLog = di.debugLog;
        //System.debug(LoggingLevel.Error, debugLog);
        //string startDelimiter = '&#124;USER_DEBUG&#124;[1]&#124;ERROR&#124;';
        string startDelimiter = '|USER_DEBUG|[1]|ERROR|';
        integer startDelimiterIndex = debugLog.indexOf(startDelimiter) + startDelimiter.length();
        integer endIndex = debugLog.indexOf('\n', startDelimiterIndex);
        string output = debugLog.substring(startDelimiterIndex, endIndex);
        return output;
    }
	*/
}