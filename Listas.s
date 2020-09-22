# Macros
		.eqv    node_next       0
		.eqv    node_str        4
		.eqv    node_size       8       # sizeof(struct node)

		.data
men1: 		.asciiz "Ingresar Nuevo Valor: 1\n"
men2:  		.asciiz "Eliminar Ultimo String: 2\n"
men3:  		.asciiz "Mostrar lista: 3\n"
men4:		.asciiz "Ingrese el string"
MAX_LENGTH:	 .word 50
primer_elemento: .word 0
list:


		.text
main:
		li  $s0,0                   # list_head = NULL
		jal menu


menu:
	  	la $a0, men1
	  	li $v0, 4
	    	syscall

	  	la $a0, men2
	  	li $v0, 4											# imprimir instrucciones
	  	syscall

	  	la $a0, men3
	  	li $v0, 4
	  	syscall

		li $v0, 5
  		syscall												# guardar instruccion
		move $t0, $v0

		li  $t1, 1
		beq $t0, $t1, ingresar

	  	li  $t1, 2
	  	beq $t0, $t1, borrar

	  	li  $t1, 3
		beq $t0, $t1, mostrar


#------------------------------------------------------------------------------------------
# Variables
# ║
# ╠═> s0: Puntero a primer primer elemento lista
# ╠═> s1: Puntero al string (Lo devuelve read_string())
# ╠═> s2: Puntero al nodo creado (Lo devuelve malloc())
# ╚═> s3: Puntedo al nodo en el que estoy parado (solo se usa si la lista no esta vacia)
#
ingresar:
		addi    $sp,$sp,-8			# reserva espacio
		sw      $ra,0($sp)			# guarda $ra
		sw      $s0,4($sp)

		jal     read_string  			# Devuelve puntero al string en V0

		# save the string pointer as we'll use it repeatedly
		move    $s1,$v0

		# insert the string
		li      $a0,node_size           # get the struct size
		jal     malloc			# Llamo a malloc
		move    $s2,$v0			# Muevo el puntero del nodo a s2

		beq $s0, $zero, vacio		# Si la lista esta vacia salto a si_vacio
		addi $s3, $s0, 0		# Como no es vacio copio la direccion del primer elemto
		jal loop_insertar		# Salto a loop_insertar
		li $s3, 0
		j menu

#---------------------------------------
si_vacio:
		move $s0, $s2
		sw $s1, node_str($s0)
		sw $s0, node_next($s0)
		li $s1, 0
		li $s2, 0
		j $ra
#---------------------------------------


loop_insertar:

		beq $s0, node_next($s3), fin_loop	# Si el nodo siguiente es igual al primer elemento salto a fin_loop

		#--- Cargo nodo siguiente en s3, seguro se puede hacer mejor
		lw $t1, node_next($s3)
		li $s3, 0
		addi $s3, $t1, 0
		#---

		j loop_insertar				# Vuelvo a iterar

fin_loop:
		sw $s2, node_next($s3)			# Cargo puntero al nodo creado en nodo_next del ultimo nodo
		sw $s1, node_str($s2)			# Cargo el puntero al string en el nodo creado
		sw $s0, node_next($s2)			# Cargo puntero al primer nodo en el nodo siguiente del creado
		j $ra

#------------------------------------------------------------------------------------------
# Devuelve V0 puntero al string
read_string:
		addi    $sp,$sp,-8
		sw      $ra,0($sp)
		sw      $s0,4($sp)

		# (Borrar) lw      $a1,MAX_STR_LEN         # $a1 gets MAX_STR_LEN

		lw      $a0,MAX_STR_LEN         # tell malloc the size
		jal     malloc                  # allocate space for string

		move    $a0,$v0                 # move pointer to allocated memory to $a0

		lw      $a1,MAX_STR_LEN         # $a1 gets MAX_STR_LEN
		li      $v0,8
		syscall				# Lee el string

		move    $v0,$a0                 # restore string address

		lw      $s0,4($sp)
		lw      $ra,0($sp)
		addi    $sp,$sp,8
		jr      $ra

#------------------------------------------------------------------------------------------

borrar:

#------------------------------------------------------------------------------------------
# Variables
# ║
# ╠═> s0: Puntero a primer primer elemento lista
# ╚═> s1: Puntedo al nodo en el que estoy parado (solo se usa si la lista no esta vacia)

mostrar:
		addi $s1, $s0, 0
loop_mostrar:

		#--- Imprimo el nodo
		la $a0, node_str($s1)
	  	li $v0, 4
	  	syscall
		#--- No se si imprimir un /n

		#--- Cargo nodo siguiente en s1, seguro se puede hacer mejor
		lw $t1, node_next($s1)
		li $s1, 0
		addi $s1, $t1, 0
		#---

		bnq $s0, node_next($s1), loop_mostrar	# Vuelvo a iterar

		#--- Imprimo el ultimo nodo
		la $a0, node_str($s1)
		li $v0, 4
		syscall
		#---

		j menu

#------------------------------------------------------------------------------------------
# Toma a0 con el tamaño de memoria a pedir
# Devuelve V0 con el puntero a la memoria pedida
malloc:
		li $v0,9
		syscall
		jr $ra

#------------------------------------------------------------------------------------------
