
---   
### Housekeeper Bee Release Note ###   

Date formate: yyyy/MM/dd   
Version: Major.{New/enhancement}.{Bug fix}   
---
Release Date: 2026/03/26	
Version: 1.12.1
Build Number: 202603260800-043

[Bug fixed]
1. Search by tag - fixed single quote cause auto-complete failed 
2. tag not allow to use single quote 
3. Storage -> item editor not support Chinese single quote 

---
Release Date: 2026/03/08    
Version: 1.12.0    
Build Number: 202603080800-042   

[New]
Export/ Import backup file
- Export a specific backup snapshot as a downloadable .zip file directly from the backup list UI.
- Import a previously exported .zip file to restore a backup snapshot into the system.   

<br/>    

⚠️Modify the **application.properties** file 

### [Update]    
Increase from 10MB to 300MB
```
spring.servlet.multipart.max-file-size=300MB
spring.servlet.multipart.max-request-size=300MB
```

### [Add] 
```
#==================================================
# Apply to vesion 1.12.0
# Export and Import backup file
#==================================================
app.backup.root=${HOUSEKEEPER_BEE_HOME}/housekeeping_bee/backup/
app.backup.temp-dir=${HOUSEKEEPER_BEE_HOME}/housekeeping_bee/temp/
app.backup.max-upload-size=300MB
app.backup.temp-retention-days=30

```
<br>

![](https://static.wixstatic.com/media/0d7edc_d7ef631632534185927402e3cbb4f555~mv2.png)

--- 
Release Date: 2026/02/27   
Version: 1.11.0   
Build Number: 202602270800-041   

[Modified]
Integrated with the vision service for object detection and OCR 
- new object detection UI and OCR UI
- application.properties added 

	Sample 
	```
	#==================================================
	# Apply to vesion 1.11.0
	# Connect to vision service
	#==================================================
	vision.api.url=https://192.168.50.102:8000
	vision.api.key=sk_lnyLXTsPSmXlueNGK_cxLwPAIQxJas99
	```

---
Release Date: 2026/02/14     
Version: 1.10.0   
Build Number: 202602140800-040   

[Modified]
New Administration Panel (v1.2.0)
Module Control: Allow users to enable or disable system modules based on their needs.

---
Release Date: 2026/02/09    
Version: 1.9.0    
Build Number: 202602092300-039   

[Modified]
- New end-points to get all registered BLE/ iBeacon list - it includes location name, box name, peripheral name, iBeacon UUI, iBeacon major and iBeacon minor  
- Add/ Edit storage box :: Added new iBeacon Manufacturer, HolyIot (model: 16032, 21014)

[Bug Fixed] 
- Fixed Add and Edit storage box UI cannot read all fields in mobile app

[Added]
- "Deep Indig" and "Morning Fizz" style sheets 

---
Release Date: 2026/01/20   
Version: 1.8.0   
Build Number: 202601202300-038   

[Modified]
- Add/ Edit Storage Item UI :: Added "Editor" to quick add/edit/delete and re-arrage storage item name and update QTY.


---
Release Date: 2026/01/16   
Version: 1.7.1    
Build Number: 202601160700-037   

Bug fix.
Report Server: The session token is missing claims that include the user code and display name. 
It allows the report server to bookmark the favorite reports.

---
Release Date: 2025/12/28   
Version: 1.7.0   
Build Number: 202512260700-036   

[Add]
Support Housekeeper Bee report server service (only support Web browser)
- Get session token 
- new end-point for report server (api/housekeeping/storage/service ...)

[Modified] - application.properties 
Added the following properties to enable the report server service 

```
#==================================================
# Apply to vesion 1.7.0
# Connect to external service
# uncomment the service you have
#==================================================
external.service.report-service.enabled=true
external.service.report-service.url=https://192.168.50.102
external.service.report-service.port=3843
external.service.report-service.secret=${service_print_server_secret}
```

[Bug fixed]
Style sheet - Search by tag Auto fill cannot show text
1. Navy Blue
2. Lavender


---
Release Date: 2025/12/14   
Version: 1.6.2   
Build Number: 202512140700-035   

[Add]
RestStorageService added "findStorageByCode" end-point for MCP server and agent use 

---
Release Date: 2025/12/12    
Version: 1.6.1   
Build Number: 202512120700-034   

Fix: critical bug cause by single quote of tag

---
Release Date: 2025/12/10    
Version: 1.6.0   
Build Number: 202512101800-033    

✨ New Features
Item Tagging Feature: You can now organize your storage items using custom tags! Use these tags to filter and search for items more quickly.

Goal: Allow searching storage box by tags. e.g. storage tags: USB, Cable, electronic, USB charger, MacBook charger.
Get better search result for AI/LLM  

Default tags allow to use: USB, TYPE-C, TYPE-A, TYPE-C, Clothe, Winter, Summer, Spring, Autumn, Tool 
```
{
"en":[
		{"electonic":["USB", "TYPE-C"]},
		{"seasonly": ["Spring", "Summer", "Autumn", "Winter"]}
],
"zh-HK":[
		{ "電子": [ "USB"，"TYPE-C" ] },
		{ "季節性": [ "春天", "夏天", "秋天", "冬天"]}
]	
}
```

[Database]
File: V1.2__storage_alter_table.sql
table: storage
field: 	change	short_desc  from 256 to 1024
		add 	tags	enhance searching  
		add 	idx_storage_tags index
		
[Files]
Object:		storage
- Model:		add attribute "tags" text array
- Repository:	add 3 queries 
- service:	add CRUD tags
- thymeleaf: enhanced storage_new.html and storage_edit.html to management the storage's tags
- MVC controller: 3 new end points for add/get/remove tags 
- REST controller: 3 new mcp end point for add/get/remove tags, called by MCP server and AI agent, require verify the API key.

---
Release Date: 2025/11/14   
Version: 1.5.0   
Build Number: 202511101800-032   

[1] Bug Fixed
[2] "About" page added "Check Update" and new page "Auto Update" and manual update - "Do Update"

P.S. You need install or update the HousekeeperBeeWebAppUpdateTool to version 1.3 or higher

---
Release Date: 2025/08/25   
Version: 1.4.0   
Build Number:   

Added
- self-signed P12 cert
- redirect to SSL connection

keytool -genkeypair -alias housekeeperbee -keyalg RSA -keysize 2048 -validity 36500 -keystore housekeeper_bee_keystore.jks -dname "CN=vneticworkshop.com, OU=fox team, O=vnetic workshop, L=HKG, ST=HKG, C=HKG" -ext SAN=DNS:127.0.0.1,IP:127.0.0.1
keytool -importkeystore -srckeystore housekeeper_bee_keystore.jks -srcalias housekeeperbee -destkeystore housekeeper_bee_keystore.p12 -deststoretype PKCS12
    
    
Data Protection: Yes, your data is encrypted during transmission even if you see "Not Secure." However, the warning indicates that you should be cautious about trusting the identity of the server.

Fixed: 
Cannot read NFC tag/ Barcode and Face ID UUID

    
---
Release Date: 2025/08/15    
Version: 1.3.0    
Build Number:     

New
- Add "Flyway" dependence to update database schema  

Bug fix
- storage location text area words count
- Storage Location and Box "description" and "remark" too length. it cannot show all text


IMPORTANT

When create SQL must drop table and then create as below:
If sql already rollout, DO NOT change it content. It will cause checksum error in flyway_schema_history.
In case it happen, the backup file cannot restore. Just delete the backup!!!!

``` 
DROP TABLE IF EXISTS dummy_01;

CREATE TABLE IF NOT EXISTS dummy_01 (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INTEGER NOT NULL,
    grade CHAR(2)
);
```

---
Release Date: 2025/08/03   
Version: 1.2.0    
Build Number:    

- Added Text Area words count
- Fine tune chart UI

---
Release Date: 2025/07/15    
Version: 1.1.0    
Build Number:   

-  provide MCP rest API end points

---
Release Date: 2025/03/07    
Version: 1.0.0    

Initial Release    

---




