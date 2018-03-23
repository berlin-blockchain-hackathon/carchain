pragma solidity ^0.4.18;
contract CarChain  {
/////////////////////// Description ///////////////////////////////
// car has own account
// Manufactures registers car.
// Car can be sold and paiid by nwe owner
// Owner  can retrieve kfz Brief and Zulassung
// Owner  can retrieve inspections
// Owner  can retrieve milage insrted by Car
// car canm pay and sell services


/////////////////////// Declarations ///////////////////////////////
  
    // // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
 
    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);




   
   
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
        address[] myCarAccts;
        RepairDone[] repairsDone;    
        
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
       bytes32 aCarSerial
       
    );
    
 
    event carSold(
        address aCarAdr, 
        address _to, 
        uint _price,
        uint counter
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
    
    // Data of a single part entry
     struct Repair {
        bytes32 reason;
        bytes32 details; 
        uint    timestamp;
        address doneBy;
        uint    price;
        bool    paid;
    }
    
    struct RepairDone{
        address theCarAdr;
        uint counter; 
    }

    


    // Data of a single car
     struct Car {
        bytes32  carSerial;   //serial number of car
        bytes32  cartype;
        address  producer;
        address  owner;
        address  nextOwner;
        uint     price;
        bool     registered;
        Milage[] milages;
        Part[]   parts;
        Repair[] repairs;
     }

     // dynamic structure of cars
     mapping(address => Car) cars;
       address[] public carAccts;

     
   
/////////////////////// Functions ///////////////////////////////
   /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function CarChain(
        uint256 initialSupply
    ) public {
        totalSupply = initialSupply; 
        balanceOf[msg.sender] = totalSupply;                    // Give the creator all initial tokens
        name = "carCoin";                                       // Set the name for display purposes
        symbol = "CC€";                                         // Set the symbol for display purposes
        provider = msg.sender;

    }

    /**
     *  transfer
     */
    function transfer(address _to, uint _value) public  {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[msg.sender] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[msg.sender] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[msg.sender] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[msg.sender] + balanceOf[_to] == previousBalances);
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function createCoins(uint256 _value) public returns (bool success) {
        require(msg.sender == provider);       // Check if the sender  is the bank
        totalSupply += _value;                 // Updates totalSupply
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burnCoins(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
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

    function displayFirm (address aFirmAdr)  public view returns (bytes32, bytes32,bytes32,  Typeenum){
       return (firms[aFirmAdr].nameOfFirm, firms[aFirmAdr].city, firms[aFirmAdr].street, firms[msg.sender].firmType);
    }   

    function setMilage (address aCarAdr, uint32 miles)  public returns (uint _noEntries) {
        /*require ((msg.sender == cars[aCarAdr].owner)||(msg.sender == aCarAdr)); 
        because || does not work
        */ 
        Milage  memory currentMilage;
        currentMilage.timestamp=now;
        currentMilage.milage=miles;
        
        cars[aCarAdr].milages.push(currentMilage) -1;
        return cars[aCarAdr].milages.length;
    }

    function getMilage (address aCarAdr, uint32 _noEntries)  view public returns (uint32, uint) {
       /* require ((msg.sender == cars[aCarAdr].owner)||(msg.sender == aCarAdr)); 
        because || does not work
        */ 
        uint32  _milage= cars[aCarAdr].milages[_noEntries].milage;
        uint  _timestamp= cars[aCarAdr].milages[_noEntries].timestamp;
        
        return (_milage, _timestamp);
    }
    

    function setPart (address aCarAdr, bytes32 _partNo, bytes32 _partType)  public  returns (uint _noEntries) {
        require (msg.sender == cars[aCarAdr].owner); 

        Part  memory currentPart;
        currentPart.timestamp   = now;
        currentPart.partNo      = _partNo;
        currentPart.partType    = _partType;
        currentPart.insertedBy  = msg.sender;
        cars[aCarAdr].parts.push(currentPart) -1;
        return cars[aCarAdr].parts.length;
    }

    function getPart (address aCarAdr, uint32 _noEntries)  view public returns (bytes32, bytes32, uint, bytes32) {
        require (msg.sender == cars[aCarAdr].owner); 
        bytes32  _partNo= cars[aCarAdr].parts[_noEntries].partNo;
        bytes32  _partType= cars[aCarAdr].parts[_noEntries].partType;
        uint  _timestamp= cars[aCarAdr].parts[_noEntries].timestamp;
        address inserter= cars[aCarAdr].parts[_noEntries].insertedBy;
        bytes32 inserterName= firms[inserter].nameOfFirm;
        
        return (_partNo, _partType, _timestamp,inserterName);
    }

    function setRepair (address aCarAdr, bytes32 _reason, bytes32 _details, uint _price)  public  returns (uint _noEntries) {
        /* require (
            (msg.sender == cars[aCarAdr].owner) || 
            (firms[msg.sender].firmType == Typeenum.workshop)
            ); 
        because || does not work
        */ 

        Repair  memory currentRepair;
        currentRepair.timestamp   = now;
        currentRepair.reason      = _reason;
        currentRepair.details     = _details;
        currentRepair.doneBy      = msg.sender;
        currentRepair.price       = _price;
        if (_price > 0) 
            currentRepair.paid    = false; 
            else 
            currentRepair.paid    = true ;
        
        cars[aCarAdr].repairs.push(currentRepair) -1;
        
        RepairDone memory currentRepairDone;
        currentRepairDone.theCarAdr = aCarAdr;
        currentRepairDone.counter = cars[aCarAdr].repairs.length;
        firms[msg.sender].repairsDone.push(currentRepairDone) -1;
        
        return cars[aCarAdr].repairs.length;
    }

    function getRepair (address aCarAdr, uint32 _noEntries)  public view returns (uint, bytes32,bytes32,bytes32, uint, bool){
        require (msg.sender == cars[aCarAdr].owner); 
        
        Repair  memory currentRepair;
        currentRepair.timestamp   = cars[aCarAdr].repairs[_noEntries].timestamp;
        currentRepair.reason      = cars[aCarAdr].repairs[_noEntries].reason;
        currentRepair.details     = cars[aCarAdr].repairs[_noEntries].details;
        currentRepair.doneBy      = cars[aCarAdr].repairs[_noEntries].doneBy;
        currentRepair.price       = cars[aCarAdr].repairs[_noEntries].price;
        currentRepair.paid        = cars[aCarAdr].repairs[_noEntries].paid;
  
        bytes32    repairFirmName= firms[currentRepair.doneBy].nameOfFirm;
  
        return (
             currentRepair.timestamp  ,
             currentRepair.reason     ,
             currentRepair.details    ,
             repairFirmName           ,
             currentRepair.price      ,
             currentRepair.paid       
        );
    }
 
     function displayRepairDone (uint32 _repNoFirm)  public view returns (uint, bytes32, bytes32, address, uint, uint, bool){
       /*     require (
                (firms[msg.sender].firmType == Typeenum.partproducer)||
                (firms[msg.sender].firmType == Typeenum.seller)||
                (firms[msg.sender].firmType == Typeenum.workshop)
            );
       because of VM errer:revert*/ 
        
            address repAdr;
            uint repNoCar;
            repAdr    = firms[msg.sender].repairsDone[_repNoFirm].theCarAdr;
            repNoCar   = firms[msg.sender].repairsDone[_repNoFirm].counter; 
            
        Repair  memory curRep;
        curRep.timestamp   = cars[repAdr].repairs[repNoCar].timestamp;
        curRep.reason      = cars[repAdr].repairs[repNoCar].reason;
        curRep.details     = cars[repAdr].repairs[repNoCar].details;
        curRep.doneBy      = cars[repAdr].repairs[repNoCar].doneBy;
        curRep.price       = cars[repAdr].repairs[repNoCar].price;
        curRep.paid        = cars[repAdr].repairs[repNoCar].paid;
  
    
        return (
             curRep.timestamp  ,
             curRep.reason     ,
             curRep.details    ,
             repAdr            ,
             repNoCar          ,
             curRep.price      ,
             curRep.paid       
        );
    }
 
   
    function payRepair (address aCarAdr,uint index) public {
        require (balanceOf[msg.sender] >= cars[aCarAdr].repairs[index].price);
        require (cars[aCarAdr].repairs[index].paid == false);
   
        transfer(cars[aCarAdr].repairs[index].doneBy,cars[aCarAdr].repairs[index].price);
        cars[aCarAdr].repairs[index].paid = true;
    }


    // register car is called by car manufacturer
    function registerCar (address aCarAdr, bytes32 aCarType, bytes32 aCarSerial) public returns (uint _noOfCars) {
        //  precondition: manufacture has created a car account 
        //  private key is stored in car computer  and at manufacturer
        
   
        require (firms[msg.sender].firmType == Typeenum.carmanufacturer); 
        require (aCarAdr != 0x0); 
 
        cars[aCarAdr].carSerial=aCarSerial;
        cars[aCarAdr].cartype=aCarType;
        cars[aCarAdr].producer=msg.sender;
        cars[aCarAdr].owner=msg.sender;
        cars[aCarAdr].nextOwner=0x0;
        
        setMilage(aCarAdr,0);
        setRepair(aCarAdr, "Factory test","final QA check", 0);
        
        if (cars[aCarAdr].registered != true) {carAccts.push(aCarAdr) -1;}
        if (cars[aCarAdr].registered != true) {firms[msg.sender].myCarAccts.push(aCarAdr) -1;}
         
        cars[aCarAdr].registered=true;

        carInfo(aCarAdr,aCarType, aCarSerial);

        return carAccts.length;
        
    }
    
    function displayCar (address aCarAdr)  public view returns (bytes32, bytes32, bytes32, bytes32, bytes32, bytes32, uint){
       return (
           firms[cars[aCarAdr].producer].nameOfFirm, 
           firms[cars[aCarAdr].owner].nameOfFirm,
           firms[cars[aCarAdr].owner].city,
           firms[cars[aCarAdr].owner].street,
           cars[aCarAdr].cartype, 
           cars[aCarAdr].carSerial,
           cars[aCarAdr].price
           );
    }   

    function displayMyCar (uint _counter)  public view returns (bytes32, bytes32, bytes32, bytes32, uint, bool, address){
           address myCarAdr;
           myCarAdr= firms[msg.sender].myCarAccts[_counter];
           bool billpaid=false;
           if (cars[myCarAdr].nextOwner == 0x0 ) billpaid=true;
        return (
           firms[cars[myCarAdr].producer].nameOfFirm, 
           firms[cars[myCarAdr].owner].nameOfFirm, 
           cars[myCarAdr].cartype, 
           cars[myCarAdr].carSerial,
           cars[myCarAdr].price,
           billpaid,
           myCarAdr
           );
    }   

 

    function sellCar (address aCarAdr, address _to, uint _price) public {
        
        require (msg.sender == cars[aCarAdr].owner);
        require (cars[aCarAdr].nextOwner == 0x0); 
        require (cars[aCarAdr].registered == true);  //it has to be a car

        uint counter;
        cars[aCarAdr].nextOwner = _to; 

        if(_price > 0) {
                cars[aCarAdr].price = _price; 
            } else {
                cars[aCarAdr].owner =_to;
            }
        
        firms[_to].myCarAccts.push(aCarAdr) -1;
        counter=firms[_to].myCarAccts.length;
        carSold (aCarAdr, _to, _price, counter);

    }
    
    
    function payCar (address aCarAdr) public {
        require (msg.sender == cars[aCarAdr].nextOwner);
        require (balanceOf[msg.sender] >= cars[aCarAdr].price);
   
        transfer(cars[aCarAdr].owner,cars[aCarAdr].price);
        cars[aCarAdr].nextOwner = 0x0; 
        cars[aCarAdr].owner= msg.sender;
    }
    
    function claimCar (address aCarAdr) public {
        require (msg.sender == cars[aCarAdr].owner);
        require (cars[aCarAdr].nextOwner != 0x0); 

        cars[aCarAdr].nextOwner =0x0; 
    }
 
    

    function getNoOfCars () public view returns (uint retno) {
       return  firms[msg.sender].myCarAccts.length;
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
      
    function getMyCarAdr (uint counter) public view returns (address retno) {
       return firms[msg.sender].myCarAccts[counter];
    }
      
   
// end of functions    
}
