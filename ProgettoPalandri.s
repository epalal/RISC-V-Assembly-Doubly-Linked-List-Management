#			Progetto Assembly RISC-V per il
#		Corso di Architetture degli Elaboratori
#					A.A. 2020/2021
#			Gestione di Liste Concatenate
#				Palandri Elena 7054433

.data		#dichiaro le stringhe e i caratteri
#listInput: .string "ADD(1) ~ ADD(a) ~ ADD() ~ ADD(B) ~ ADD ~ ADD(9) ~PRINT~SORT(a)~PRINT~DEL(bb)~DEL(B)~PRINT~REV~PRINT"
listInput: .string "ADD(1) ~ ADD(a) ~ ADD(a) ~ ADD(B) ~ ADD(;) ~ ADD(9) ~PRINT~SORT~PRINT~DEL(b) ~DEL(B)~PRI~REV~PRINT"
tilde: .byte 126
space: .byte 32

.text
Main:		#inserisco i vari valori nei registri
	la s0 listInput				
	lw s1 tilde					
	lw s2 space					
  	li a3 0x00010000			#indirizzo base
	li a5 0x00010000            #indirizzo per LFSR
	li t3 0                     #contatore elementi

WhichOperation:	#cerco l'operazione da eseguire
	add t1 t3 s0		#metto in t1 l'indirizzo attuale
    lb t2 0(t1)			#metto in t2 l'elemento attuale
    li t0 65           	#metto in t0 il carattere 65=A
    beq t2 t0 TestAdd	#t2=A? Se si' vai a TestAdd
    li t0 68          
    beq t2 t0 TestDel 	#t2=D? Se si' vai a TestDel
	li t0 80           
    beq t2 t0 TestPrint	#t2=P? Se si' vai a TestPrint
    li t0 83          
    beq t2 t0 TestSort	#t2=S? Se si' vai a TestSort
    li t0 82            
    beq t2 t0 TestRev	#t2=R? Se si' vai a TestRev
	beq t2 zero End		#t2=0? Se si' vai a End, la stinga e' terminata
    bne t2 s2 NextOperation	#se non trovo nessuna corrispondenza cerco un'altra operazione

NextElement:  #scorro all'elemento successivo
    addi t3 t3 1	
    j WhichOperation
  
NextOperation:	#cerca l'operazione successiva
    addi t3 t3 1
    add t1 t3 s0 
    lb t2 0(t1)	
    beq t2 zero End		#siamo alla fine della lista
    bne t2 s1 NextOperation #cerco fino a quando non trovo la tilde
    addi t3 t3 1
    j WhichOperation	#se la trovo torno a WhichOperation

TestOperation:
    addi a6 a6 1
    add t1 a6 s0
    lb a2 0(t1)
    beq a2 zero WrittenCorrectly        #la lista e' finita e l'operazione e'scritta bene
   	beq a2 s1  WrittenCorrectly         #c'e' la tilde, l'operazione e' scritta bene
    bne a2 s2  NotWrittenCorrectly     #a meno che non ci sia uno spazio, l'operazione non e'scritta bene
    j TestOperation
      
NotWrittenCorrectly:	#se e'scritta male ritorna 0
    addi a1 zero 0
    ret

WrittenCorrectly:		#se e'scritta bene ritorna 1
    addi a1 zero 1
    ret 

TestAdd:
   	li t0 68                #carico D e contollo
    addi t3 t3 1			#in t3 salvo la posizione in cui sono arrivata
    add t1 t3 s0            #in t1 ho l'indirizzo attuale
    lb t2 0(t1)               
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation
      
    li t0 68                  #carico D e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation
      
    li t0 40                   #carico ( e controllo
    addi t3 t3 1
    add t1 t3 s0       
    lb t2 0(t1)
    bne t2 t0 NextOperation
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    blt t2 s2 NextOperation
    bgt t2 s1 NextOperation
    add a0 t2 zero
      
    li t0 41                  #carico ) e controllo  
    addi t3 t3 1
    add t1 t3 s0       
    lb t2 0(t1)
    beq t2 zero End                 
    beq t2 s1 WhichOperation    #se trovo una tilde vado a WhichOperation
    bne t2 t0 NextOperation
    
    add a6 t3 zero                #inizializzo un contatore per capire a che punto della lista sono
                                    #salvo t3 in a6, il che vuol dire quando faccio la funzione uso a6 e so dove sono arrivato
    jal TestOperation
    beq a1 zero NextOperation
    jal Add                      #e' tutto corretto, posso fare la Add
    j NextOperation

Add:  
	li t0 0xFFFFFFFF		#salvo NULL in t0
    bne s8 zero LFSR 		#se s8=0 siamo nel primo nodo
    add a1 a3 zero          #prendo l'indirizzo base
    sw t0 0(a1)             #PBACK=NULL
    sb a0 4(a1)             #valore contenuto nel nodo
    sw t0 5(a1)             #PAHEAD=NULL
    addi s8 s8 1            #contatore delle Add
    add s4 a1 zero          #salvo l'indirizzo base del primo elemento
    ret                     #torno a TestAdd perche' era il primo inserimento 

NextAdd:     
    li t4 0xFFFFFFFF			
    sw t4 5(t2)                  #PAHEAD = NULL
    sb a0 4(t2)                  #carattere da aggiungere
    sw s4 0(t2)                  #PBACK nuovo nodo punta al nodo precedente
    sw t2 5(s4)                  #PAHEAD nodo precedente punta al nuovo nodo
    add s4 t2 zero               #nuovo indirizzo base
    addi s8 s8 1                 #contatore Add++
    ret

LFSR:					#shift 16-k bit(k=16,14,13... seguendo il polinomio)
	srli t2 a5 0
    srli t4 a5 2
    xor t2 t2 t4
    srli t4 a5 3
    xor t2 t2 t4
    srli t4 a5 5
    xor t2 t2 t4
    slli t4 t2 15
    srli t2 a5 1
    or a5 t4 t2                 
    li t5 0x0000FFFF
    and t2 a5 t5              
    li t5 0x00010000
    or t2 t2 t5                  #indirizzo casuale calcolato
    j NextAdd

TestDel:
    li t0 69                      #carico E e controllo
    addi t3 t3 1
    add t1 t3 s0                  
    lb t2 0(t1)                   
    beq t2 zero End
    beq t2 s1 NextElement 
    bne t2 t0 NextOperation
     
    li t0 76                      #carico L e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation
    
    li t0 40                      #carico ( e controllo 
    addi t3 t3 1
    add t1 t3 s0       
    lb t2 0(t1)
    bne t2 t0 NextOperation

    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    blt t2 s2 NextOperation		#il carattere deve essere <126
    bgt t2 s1 NextOperation		#il carattere deve essere >31
    add a0 t2 zero
      
    li t0 41                      #carico ) e controllo
    addi t3 t3 1
    add t1 t3 s0       
    lb t2 0(t1)
    beq t2 zero End        
    beq t2 s1 WhichOperation  
    bne t2 t0 NextOperation
    add a6 t3 zero          
      
    jal TestOperation
    beq a1 zero NextOperation
    jal Del              #e' tutto corretto, posso fare la Del
	li s3 0x00010000            #indirizzo per Del
    add s3 t2 zero      # se non vengono effettuate delle cancellazioni, salvo in s3 nuovamente l'indirizzo Base
    j NextOperation

Del:   
    li t0 0xFFFFFFFF    
    beq s8 zero EndDel          #se la lista ? vuota vado a EndDel
    beq s3 t0 EndDel
    add t6 s3 zero                 
    lb t1 4(t6)                   #trovo il primo carattere
    li t4 0x00010000
    beq t6 t4 CharTop
       
ContinueTop:
    beq t6 s4 CharLast

Delete:
    bne t1 a0 ContinueDel        #se t1 ? diverso da a0 continuo a cercare
    lw t2 0(t6)                  #PBACK
    lw t5 5(t6)                  #PAHEAD
    sw t5 5(t2)                  #PAHEAD del precedente ora punta al successivo
    sw t2 0(t5)                  #PBACK del successivo ora punta al precedente
    addi s8 s8 -1    			 #ho eliminato un nodo, aggiorno il contatore degli elementi aggiunti
    j EndDel
       
Top:
    lw t2 5(t6)                   #PAHEAD
    sw t0 0(t2)                   #elimino il primo nodo impostando il PBACK del secondo uguale a NULL
    add s3 t2 zero                #s3 nuovo top
    ret
       
Last:
    lw t2 0(t6)            
    sw t0 5(t2)                   #PAHEAD penultimo NULL
    add s4 t2 zero                #salvo il nuovo ultimo
    addi s8 s8 -1
    j EndDel
       
ContinueDel:
    lw t6 5(t6)                   #scorro all'elemento successivo
    add s3 t6 zero
    j Del                
       
CharTop: #trovo il carattere da eliminare in cima
    beq t1 a0 Top
    j ContinueTop
       
CharLast:	#trovo il carattere da elminare in fondo
    beq t1 a0 Last
    j Delete
	  
EndDel:
    li t2 0x00010000
    ret

TestSort:
    li t0 79                      #carico O e controllo  
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 WhichOperation
	bne t2 t0 WhichOperation
     
    li t0 82                       #carico R e controllo 
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 WhichOperation
	bne t2 t0 WhichOperation
     
    li t0 84                      #carico T e controllo 
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 WhichOperation
	bne t2 t0 WhichOperation

	add a6 t3 zero
	jal TestOperation
	beq a1 zero NextOperation
	jal Sort                #e' tutto corretto, posso fare il Sort 
	j NextOperation

Sort:
    li t4 0				#contatore per scambi
    add a3 s3 zero
    lb t1 4(a3) 		#prendo il carattere
    blt t1 s2 EndSort	#carattere <32 EndSort
    li s2 2
    blt s8 s2 EndSort	#n.elementi nella lista <2 EndSort
 
IsCapital:
    li t0 65
    blt t1 t0 IsNumber
    li t0 90
    bgt t1 t0 IsLowercase
    addi t1 t1 97
    addi s10 s10 1
    j NextNodes
     
IsLowercase: 
    li t0 97
    blt t1 t0 IsCharExtra2
    li t0 122
    bgt t1 t0 IsCharExtra1
    addi t1 t1 39
    addi s10 s10 1
    j NextNodes
     
IsNumber: 
    li t0 48
    blt t1 t0 IsCharExtra
    li t0 57 
    bgt t1 t0 IsCharExtra1
    addi t1 t1 78
    addi s10 s10 1
    j NextNodes
     
IsCharExtra:                     #Racchiude tutte le altre categorie di caratteri EXTRA la di fuori delle sottostanti
    addi s10 s10 1
    j NextNodes 
     
IsCharExtra1:                    #caratteri compresi tra 57 e 65 
    li t0 65                 
    blt t1 t0 IsCharExtra
     
IsCharExtra2:                    #caratteri compresi tra 90 e 97
    li t0 90                  
    bgt t1 t0 IsCharExtra
     
Tests: 
    li s6 0xFFFFFFFF
    beq a6 s6 Again			#fine lista
    blt t1 s2 EndSort		#carattere <32
  
Capital:
    li t0 65
    blt t1 t0 Numbers
    li t0 90
    bgt t1 t0 Lowercase
    addi t1 t1 97
    addi s10 s10 1
    j NextNodes
     
Lowercase:
    li t0 97
    blt t1 t0 Extra2
    li t0 122
    bgt t1 t0 Extra
    addi t1 t1 39
    addi s10 s10 1
    j NextNodes  
     
Numbers:
    li t0 48
    blt t1 t0 Extra
    li t0 57 
    bgt t1 t0 Extra1
    addi t1 t1 78
    addi s10 s10 1
    j NextNodes  

Extra:                              #caratteri Extra oltre a quelli gi? visti
    addi s10 s10 1
    j NextNodes 
     
Extra1:                             #caratteri compresi tra 57 e 65
    li t0 65                 
    blt t1 t0 Extra
     
Extra2:                             #caratteri compresi tra 90 e 97
    li t0 90                  
    bgt t1 t0 Extra
     
NextNodes:				  
    li t0 2
    beq s10 t0 BubbleSort	#se ho trovato 2 nodi faccio il Sort
    add t5 t1 zero              #primo nodo
    lw a6 5(a3)                    
    lb t1 4(a6)					#carico il successivo
    j Tests
      
Again:
    li a1 0
    beq t4 a1 EndSort
    li t4 0
    add s10 zero zero
    add a6 zero zero
    j Sort
    
BubbleSort:
    bgt t5 t1 Swap
    lw a3 5(a3)
    lb t1 4(a3)
    addi s10 s10 -2
    j Tests
  
Swap:
    addi t4 t4 1
    lb t2 4(a3)		#carico i caratteri
    lb t6 4(a6)
    sb t2 4(a6)		#salvo i caratteri invertendoli di posizione
    sb t6 4(a3)
    lw a3 5(a3)		#nodo successivo
    lb t1 4(a3)		#salvo il carattere
    addi s10 s10 -2 
    j Tests
	
EndSort:
    ret

TestRev:
    li t0 69                     #carico E e controllo
    addi t3 t3 1
    add t1 t3 s0       
    lb t2 0(t1) 
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation

    li t0 86                      #carico V e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation

   	add a6 t3 zero
	jal TestOperation
	beq a1 zero NextOperation
	jal Rev               #e' tutto corretto, posso fare la Rev 
	j NextOperation

Rev: 
    li t6 2
    blt s8 t6 EndRev
    add t5 s3 zero
    add t6 s4 zero
    lb t0 4(t5)                 #carico il carattere in testa in t0
    lb t1 4(t6)                 #carico il carattere in coda in t1
    sb t0 4(t6)   				#metto t0 coda              
    sb t1 4(t5)                 #metto t1 in testa
      
LoopRev:
    lw t5 5(t5)             #scorro dalla testa fino alla coda
    lw t6 0(t6)             #scorro dalla coda alla testa
    beq t5 t6 EndRev		#puntano allo stesso elemento, esco
    lw t4 0(t5)
    beq t4 t6 EndRev        #se si incrociano sono pari, esco
    lb t0 4(t5)
    lb t1 4(t6)
    sb t0 4(t6)
    sb t1 4(t5)             #scambio gli elementi 
    j LoopRev
       
EndRev:
    ret

TestPrint:
    li t0 82                       #carico R e controllo
    addi t3 t3 1
    add t1 t3 s0                  
    lb t2 0(t1)                  
    beq t2 zero End
    beq t2 s1 NextElement
    bne t2 t0 NextOperation
      
    li t0 73                      #carico I e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
	beq t2 s1 NextElement
    beq t2 s1 WhichOperation
      
    li t0 78                      #carico N e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
	beq t2 s1 NextElement
    beq t2 s1 WhichOperation
      
    li t0 84                      #carico T e controllo
    addi t3 t3 1
    add t1 t3 s0
    lb t2 0(t1)
    beq t2 zero End
	beq t2 s1 NextElement
    beq t2 s1 WhichOperation 
      
    add a6 t3 zero
	jal TestOperation
	beq a1 zero NextOperation
	jal Print                     #e' tutto corretto, posso fare la Print 
	j NextOperation

Print:	#scorro tutti gli elementi finche' non trovo NULL
	li s3 0x00010000            #indirizzo per Print
	li t2 0xFFFFFFFF
    beq s3 t2 EndPrint
    add a4 s3 zero 
       
LoopPrint:
    beq a4 t2 EndPrint
    lb a0 4(a4)            #a0 e' il carattere da stampare
    li a7 11
    ecall			
    lw a4 5(a4)
    j LoopPrint
       
EndPrint:
    la a0, space
	li a7,4
	ecall
    ret
         
End:
    add a7 a7 zero