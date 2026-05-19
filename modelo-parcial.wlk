// Nerv
object nerv {
  const property evas = []
  const pilotos = []

  method registrarPiloto(piloto) { pilotos.add(piloto) }
  method registrarEva(eva) { evas.add(eva) }
  method registrarPilotos(piloto) { pilotos.addAll(piloto) }
  method registrarEvas(eva) { evas.addAll(eva) }

  method echarPiloto(piloto) { pilotos.remove(piloto) }
  method echarEva(eva) { evas.remove(eva) }
  method echarPilotos(piloto) { pilotos.removeAll(piloto) }
  method echarEvas(eva) { evas.removeAll(eva) }

  method intentarSincro(eva, piloto) {
    if (self.puedenSincronizar(eva, piloto)) {
      eva.efectoDeSincroCon(piloto)
      piloto.efectoDeSincroCon(eva)
    } else {
      self.error("No se pudieron sincronizar")
    }
  }

  method puedenSincronizar(eva, piloto) = eva.puedeSincronizarCon(piloto) and piloto.puedeSincronizarCon(eva)
  method ordenarAPilotoSincroConTodos(piloto) {
    evas.forEach({ e => self.intentarSincro(e, piloto) })
  }
  method todosLosPilotosPuedenSincronizar() = pilotos.all({ p => self.algunEvaPuedeSincronizarCon(p) })
  method algunEvaPuedeSincronizarCon(piloto) = evas.any({ e => self.puedenSincronizar(e, piloto) })
  method promedioDePuntosDeEntrenamiento() {
    // Usamos sum con un bloque (transformer) y dividimos por el total
    return pilotos.sum({ p => p.puntosDeEntrenamiento() }) / pilotos.size()
  }

  method cadaEvaPuedeSerUsadoPorAlgunPiloto() {
    // Todos los evas deben tener al menos un piloto compatible
    return evas.all({ e => pilotos.any({ p => self.puedenSincronizar(e, p) }) })
  }
}

// Evas
object eva01 {
  var campoAt = 2110
  var energia = 100

  method campoAt() = campoAt
  method efectoDeSincroCon(piloto) {
    energia -= 25
    campoAt = 2150.min(campoAt+1)
  }
  method recargarEnergia(horas) { energia = 100.min(energia+30*horas) }

  method puedeSincronizarCon(piloto) = piloto.puntosDeEntrenamiento() >= 4 and energia > 30
  method puntosQueOtorga() = 2
}

object eva02 {
  var energia = 100
  var modo = estandar
  
  method campoAt() = 2114
  method efectoDeSincroCon(piloto) {
    energia -= modo.consumo()
  }
  method recargarEnergia(horas) { energia = 100.min(energia+25*horas) }
  method cambiarModo(modoNuevo) { modo = modoNuevo }

  method puedeSincronizarCon(piloto) = piloto.puntosDeEntrenamiento() >= 2 and energia > 20
  method puntosQueOtorga() = modo.puntosQueOtorga()
}

//Modos del eva02

object estandar {
  method consumo() = 10
  method puntosQueOtorga() = 1
}

object ataque {
  method consumo() = 20
  method puntosQueOtorga() = 3
}

object berserk {
  method consumo() = 35
  method puntosQueOtorga() = 6
}

object eva00 {
  var campoAt = 2100
  
  method campoAt() = campoAt

  //Fuerza debe ser >= 0
  method mejorarCampoAt(fuerza) { campoAt = 2150.min(campoAt+fuerza) }
  method efectoDeSincroCon(piloto) { }
  
  method puedeSincronizarCon(piloto) = true
  method puntosQueOtorga() = 1
}

// Pilotos

object asuka {
  var property puntosDeEntrenamiento = 5
  var ultimoEvaSincronizado = eva00

  method efectoDeSincroCon(eva) { 
    ultimoEvaSincronizado = eva
    puntosDeEntrenamiento += eva.puntosQueOtorga()
  }
  method puedeSincronizarCon(eva) = eva.puedeSincronizarCon(self)
  method estaSatisfecha() = ultimoEvaSincronizado.campoAt() > 2115
}

object shinji {
  var property puntosDeEntrenamiento = 2
  var estaCansado = false
  const evasSincronizados = []

  method efectoDeSincroCon(eva) {
    puntosDeEntrenamiento += eva.puntosQueOtorga()
    estaCansado = true
    evasSincronizados.add(eva)
  }
  method descansar() { estaCansado = false }
  method puedeSincronizarCon(eva) = eva.puedeSincronizarCon(self) and !estaCansado
  method estaSatisfecha() = nerv.evas().all({ e => evasSincronizados.contains(e) })

  // evas del cuartel = [ eva0, eva1 ]

  // evasSincronizados = [ eva1, eva0, eva1 ]
  // evasSincronizados = [ eva1, eva0, eva2 ]
  // evasSincronizados = [ eva1 ] 
}

object rei {
  var property puntosDeEntrenamiento = 0
  var cantidadSincros = 0

  method efectoDeSincroCon(eva) {
    puntosDeEntrenamiento += eva.puntosQueOtorga()
    cantidadSincros += 1
  }
  method puedeSincronizarCon(eva) = eva.puedeSincronizarCon(self) and eva.campoAt() >= 2110 and cantidadSincros < 5
  method estaSatisfecha() = cantidadSincros > 0
}

