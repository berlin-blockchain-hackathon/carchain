pragma solidity ^0.4.18;
contract CarChain  {
/////////////////////// Description ///////////////////////////////
// car has own account
// Manufactures registers car.
// Buyer can retrieve kfz Brief and Zulassung


/////////////////////// Declarations ///////////////////////////////
  
    // Data of a single firm like carproducer, part manufacturer, repair workshop
    
    address provider; //provider of the whole contract
    
    // Type of a single firm
    enum Typeenum {unknown, carmanufacturer, partproducer, workshop, seller, customer}
    
    struct Firm {
        bytes32 nameOfFirm;
        bytes32 city;
        bytes32 street;
        Typeenum firmType;
        bool registered;
        
    }
     
    event firmInfo(
       bytes32 eName
    );
    

    // dynamic structure of firms
    mapping(address => Firm) firms;
    
    address[] public firmAccts;
    
    event carInfo(
       address eCarAddress,
       bytes32 eType,
       bytes32 eSerial
    );
    
 
    // Data of a single milage entry
     struct Milage {
        uint32 milage;
        uint  timestamp;
          }
          

    // Data of a single part entry
     struct Part {
        bytes32 partNo;
        bytes32 partType; 
        uint    timestamp;
        address insertedBy;
    }
    

    // Data of a single car
     struct Car {
        bytes32  carSerial;   //serial number of car
        bytes32  cartype;
        address  producer;
        address  owner;
        bool     registered;
        Milage[] milages;
        Part[]   parts;
     }

     // dynamic structure of cars
     mapping(address => Car) cars;
       address[] public carAccts;

     
   
/////////////////////// Functions ///////////////////////////////

    function CarChain() public {
        provider = msg.sender;
        // todo assign car contigents
        }

 
    function registerFirm (bytes32 aFirmName, bytes32 aFirmLocation,bytes32 aFirmStreet, Typeenum aFirmType) public returns (uint retno) {
        firms[msg.sender].nameOfFirm=aFirmName;
        firms[msg.sender].city=aFirmLocation;
        firms[msg.sender].street=aFirmStreet;
         firms[msg.sender].firmType=aFirmType;
   
        if (firms[msg.sender].registered != true) {firmAccts.push(msg.sender) -1;}
        firms[msg.sender].registered=true;

        return firmAccts.length;
    }

    function displayFirm (address aFirmAdr)  public constant returns (bytes32, bytes32,bytes32,  Typeenum){
       return (firms[aFirmAdr].nameOfFirm, firms[aFirmAdr].city, firms[aFirmAdr].street, firms[msg.sender].firmType);
    }   

    function setMilage (address aCarAdr, uint32 miles)  public returns (uint _noEntries) {
        if (msg.sender != cars[aCarAdr].owner) return; 

        Milage  memory currentMilage;
        currentMilage.timestamp=now;
        currentMilage.milage=miles;
        
        cars[aCarAdr].milages.push(currentMilage) -1;
        return cars[aCarAdr].milages.length;
    }

    function getMilage (address aCarAdr, uint32 _noEntries)  view public returns (uint32, uint) {
        if (msg.sender != cars[aCarAdr].owner) return; 
        uint32  _milage= cars[aCarAdr].milages[_noEntries].milage;
        uint  _timestamp= cars[aCarAdr].milages[_noEntries].timestamp;
        
        return (_milage, _timestamp);
    }
    
    // register car is called by car manufacturer
    function registerCar (address aCarAdr, bytes32 aCarType, bytes32 aCarSerial) public returns (uint _noOfCars) {
        //  precondition: manufacture has created a car account 
        //  private key is stored in car computer  and at manufacturer
        
   
       if (firms[msg.sender].firmType != Typeenum.carmanufacturer) return; 
        //  carmanufacturers can create cars only 
        cars[aCarAdr].carSerial=aCarSerial;
        cars[aCarAdr].cartype=aCarType;
        cars[aCarAdr].producer=msg.sender;
        cars[aCarAdr].owner=msg.sender;
        setMilage(aCarAdr,0);
        
        if (cars[aCarAdr].registered != true) {carAccts.push(aCarAdr) -1;}
        cars[aCarAdr].registered=true;

        carInfo(aCarAdr,aCarType, aCarSerial);

        return carAccts.length;
        
    }
    
    function displayCar (address aCarAdr)  public constant returns (bytes32, bytes32, bytes32, bytes32, bytes32, bytes32){
       return (
           firms[cars[aCarAdr].producer].nameOfFirm, 
           firms[cars[aCarAdr].owner].nameOfFirm,
           firms[cars[aCarAdr].owner].city,
           firms[cars[aCarAdr].owner].street,
           cars[aCarAdr].cartype, 
           cars[aCarAdr].carSerial
           );
    }   

    function sellCar (address aCarAdr, address _to) public {
        if (msg.sender != cars[aCarAdr].owner) return; 
        cars[aCarAdr].owner= _to;
    }


    function setPart (address aCarAdr, bytes32 _partNo, bytes32 _partType)  public  returns (uint _noEntries) {
        if (msg.sender != cars[aCarAdr].owner )  return; 

        Part  memory currentPart;
        currentPart.timestamp   = now;
        currentPart.partNo      = _partNo;
        currentPart.partType    = _partType;
        currentPart.insertedBy  = msg.sender;
        cars[aCarAdr].parts.push(currentPart) -1;
        return cars[aCarAdr].parts.length;
    }

    function getPart (address aCarAdr, uint32 _noEntries)  view public returns (bytes32, bytes32, uint, bytes32) {
        if (msg.sender != cars[aCarAdr].owner ) return; 
        bytes32  _partNo= cars[aCarAdr].parts[_noEntries].partNo;
        bytes32  _partType= cars[aCarAdr].parts[_noEntries].partType;
        uint  _timestamp= cars[aCarAdr].parts[_noEntries].timestamp;
        address inserter= cars[aCarAdr].parts[_noEntries].insertedBy;
        bytes32 inserterName= firms[inserter].nameOfFirm;
        
        return (_partNo, _partType, _timestamp,inserterName);
    }

    
    
    function getNoOfCars () public view returns (uint retno) {
       return carAccts.length;
    }

    function getNoOfFirms () public view returns (uint retno) {
       return firmAccts.length;
    }
    
    function getFirmAdr (uint counter) public view returns (address retno) {
       return firmAccts[counter];
    }
    
    function getCarAdr (uint counter) public view returns (address retno) {
       return carAccts[counter];
    }
      
    
    
// end of functions    
}
