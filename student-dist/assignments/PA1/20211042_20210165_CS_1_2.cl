class List {  
   isNil() : Bool { true }; 
   head()  : String { { abort(); ""; } }; 
   tail()  : List { { abort(); self; } }; 
   cons(i : String) : List { 
      (new Cons).init(i, self) 
   }; 
}; 
class Cons inherits List { 
   car : String;  
   cdr : List;  
   isNil() : Bool { false }; 
   head()  : String { car }; 
   tail()  : List { cdr }; 
   init(i : String, rest : List) : List { 
      { 
  car <- i; 
  cdr <- rest; 
  self; 
      } 
   }; 
}; 
class Main inherits IO {  
    myList : List <- new List; 
    push(i : String) : List { 
      { 
         myList <- myList.cons(i); 
         myList; 
      } 
    }; 
    pop() : List { 
        { 
            if not myList.isNil() then{ 
                myList <- myList.tail();   
            }  
            else{ 
                out_string(""); 
            }                
            fi; 
            myList;  
        } 
    }; 
    print_list(l : List) : Object { 
      { 
        if l.isNil() then { 
          out_string("\n");  
        }  
        else { 
            out_string(l.head());   
            out_string(" ");     
            print_list(l.tail());    
        } 
        fi; 
      } 
    }; 
    display_stack() : Object { 
      { 
        print_list(myList);   
        self;   
      } 
    }; 
 currentSize : Int <- 0 ;  
   size() : Int { 
  let newList : List <- myList in     
    let sz : Int <- 0 in               
    { 
        while not newList.isNil() loop { 
            sz <- sz + 1;             
            newList <- newList.tail();  
        } 
        pool; 
        currentSize <- sz; 
        sz;   
    } 
}; 
top1 : String <- ""; 
top2 : String <- ""; 
intTop1 : Int <- 0; 
intTop2 : Int <- 0; 
sum : Int <- 0; 
    execute() : Object{ 
      { 
         let ob : A2I <- new A2I in   
         if myList.isNil() then { 
          out_string("");  
         }  
         else if(myList.head() = "s") then {
myList <- pop(); 
            currentSize <-  currentSize -1; 
             if (  2 <= currentSize ) then { 
                 top1  <- myList.head();    
                myList <- myList.tail();  
                 top2  <- myList.head();   
                myList <- myList.tail();   
                myList <- myList.cons(top1);   
                myList <- myList.cons(top2);    
             } 
             else { 
               out_string("");  
             } 
             fi; 
         } 
         else if (myList.head() = "+") then { 
            myList <- pop(); 
            currentSize <-  currentSize -1; 
         let tempList : List <- myList in 
         if ( 2 <= currentSize ) then { 
                 top1  <- tempList.head();    
                tempList <- tempList.tail();   
                 top2  <- tempList.head();   
                tempList <- tempList.tail();   
               if ((top1 = "s" )) then{ 
                     out_string(""); 
                } 
               else if ((top1 = "+" )) then{ 
                     out_string(""); 
                } 
                else if ((top2 = "s" )) then{ 
                     out_string(""); 
                } 
                else if ((top2 = "+" )) then{ 
                     out_string(""); 
                } 
               else{
                top1  <- myList.head();    
                myList <- myList.tail();  
                top2  <- myList.head();   
                myList <- myList.tail();   
                 intTop1  <- ob.a2i(top1);    
                 intTop2  <- ob.a2i(top2);   
                 sum  <- intTop1 + intTop2; 
                 myList <- myList.cons(ob.i2a(sum));  
                } 
                fi fi fi fi; 
             } 
             else { 
               out_string("");  
             } 
             fi; 
         } 
         else { 
         out_string(""); 
         } 
         fi fi fi ; 
          self;    
      } 
    }; 
    main() : Object {     
        let flag : Bool <- true in {    
             let ob : A2I <- new A2I in   
            while flag loop {  
                out_string(">");  
                let input : String <- in_string() in {    
                    if (input = "x") then {  
                        flag <- false; }  
                     else if (input = "s") then {  
                        push(input); 
                        currentSize <- size();  }  
                     else if (input = "d") then {  
                         display_stack(); }  
                     else if (input = "+") then {  
                        push(input); 
                        currentSize <- size(); }  
                     else if (input = "e") then {  
                        currentSize <- size();  
                          execute(); }  
                     else {  
                         push(input); 
                         currentSize <- size(); }  
                     fi fi fi fi fi;     
};  }  pool;    
   }   
 };    
};   
(*This stack machine uses a linked list to manage a stack of strings, with basic operations for adding and removing elements.
The Main class allows pushing items to the stack, popping the top item,
displaying the stack, and performing operations like adding the top two numbers and swapping them.
The execute method interprets commands: "+" pops and adds the top two numbers, while "s" swaps them if possible. 
The main method reads user input to control these operations, updating the stack and displaying its contents interactively.*)