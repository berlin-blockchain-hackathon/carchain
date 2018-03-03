pragma solidity ^0.4.18;
contract CarChain  {
/////////////////////// Description ///////////////////////////////
// car has own account
// Manaufactures registers car.
// Buyer can retrieve kfz Brief and Zulassung


/////////////////////// Declarations ///////////////////////////////
  
    // Data of a single firm like carproducer, part manufacturer, repair workshop
    
    address provider; //provider of the whole contract
    
    // Type of a single firm
    enum Typeenum {carmanufacturer, partproducer, workshop, seller, customer}
    
    struct Firm {
        bytes32 nameOfFirm;
        bytes32 city;
        bytes32 street;
        Typeenum firmType;
        bool registered;
        
    }
     
    
    // dynamic structure of firms
    mapping(address => Firm) firms;
    uint32 nooffirms=0;
    
 
    // Data of a single milage entry
     struct Milage {
        uint32 milage;
        uint  timestamp;
          }

    
    // Data of a single car
     struct Car {
        bytes32 carSerial;   //serial number of car
        bytes32 cartype;
        address producer;
        address owner;
     }

     // dynamic structure of cars
     mapping(address => Car) cars;
   
    // counters 
    uint32 noOfCars=0;
    
/////////////////////// Functions ///////////////////////////////

    function CarChain() public {
        provider = msg.sender;
        // assign car contigents
        }

 
    function registerFirm (bytes32 aFirmName, bytes32 aFirmLocation,bytes32 aFirmStreet, Typeenum aFirmType) public returns (uint32 retno) {
        firms[msg.sender].nameOfFirm=aFirmName;
        firms[msg.sender].city=aFirmLocation;
        firms[msg.sender].street=aFirmStreet;
     
        firms[msg.sender].firmType=aFirmType;
        firms[msg.sender].registered=true;
        nooffirms++;
        return nooffirms;
    }

    function displayFirm (address aFirmAdr)  public constant returns (bytes32, bytes32,bytes32){
       return (firms[aFirmAdr].nameOfFirm, firms[aFirmAdr].city,firms[aFirmAdr].street);
    }   


    // register car is called by car manufacturer
    function registerCar (address aCarAdr, bytes32 aCarType, bytes32 aCarSerial) public returns (uint32 _noOfCars) {
        //  precondition: manufacture has created a car account 
        //  private key is stored in car computer  and at manufacturer
        
   
       if (firms[msg.sender].firmType != Typeenum.carmanufacturer) return; 
        //  carmanufacturers can create cars only 
     
        
        cars[aCarAdr].carSerial=aCarSerial;
        cars[aCarAdr].cartype=aCarType;
        cars[aCarAdr].producer=msg.sender;
        cars[aCarAdr].owner=msg.sender;

        noOfCars++;
        
        return noOfCars;
    }
    
    function displayCar (address aCarAdr)  public constant returns (bytes32, bytes32, bytes32, bytes32){
       return (
           firms[cars[aCarAdr].producer].nameOfFirm, 
           firms[cars[aCarAdr].owner].nameOfFirm, 
           cars[aCarAdr].cartype, 
           cars[aCarAdr].carSerial
           );
    }   

   function sellCar (address aCarAdr, address _to) public {
        if (msg.sender != cars[aCarAdr].owner) return; 
        cars[aCarAdr].owner= _to;
   }

    
    function getNoOfCars () public constant returns (uint retno) {
    return noOfCars;
    }
    
    
// end of functions    
}
