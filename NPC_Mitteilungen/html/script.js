let currentNPCs = [];
let selectedNPC = null;
let capturedCoords = null;

// Listen for messages from client.lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        document.getElementById('app').style.display = 'block';
        loadNPCs();
    } else if (data.action === 'close') {
        document.getElementById('app').style.display = 'none';
    } else if (data.action === 'updateNPCs') {
        currentNPCs = data.npcs || [];
        renderNPCList();
    } else if (data.action === 'coordsCaptured') {
        capturedCoords = data.coords;
        updateCoordsDisplay();
    }
});

// Close UI
function closeUI() {
    document.getElementById('app').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// ESC key to close
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

// Load NPCs from server
function loadNPCs() {
    fetch(`https://${GetParentResourceName()}/getNPCs`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(response => response.json())
      .then(data => {
          currentNPCs = data.npcs || [];
          renderNPCList();
      });
}

// Render NPC list
function renderNPCList() {
    const listContainer = document.getElementById('npcList');
    
    if (currentNPCs.length === 0) {
        listContainer.innerHTML = '<div style="color: #aaa; text-align: center; padding: 20px;">Keine NPCs vorhanden</div>';
        return;
    }
    
    listContainer.innerHTML = currentNPCs.map((npc, index) => {
        const firstMessage = npc.messages && npc.messages.length > 0 ? npc.messages[0] : 'Keine Nachricht';
        const modelName = npc.pedModel || 'Unbekannt';
        
        return `
            <div class="npc-item ${selectedNPC === index ? 'active' : ''}" data-index="${index}">
                <div class="npc-item-header">
                    <div class="npc-item-title">NPC #${index + 1}: ${modelName}</div>
                    <div class="npc-item-actions">
                        <button class="btn-spawn" onclick="spawnNPC(${index})">Spawn</button>
                        <button class="btn-edit" onclick="editNPC(${index})">Edit</button>
                    </div>
                </div>
                <div class="npc-item-info">
                    ${firstMessage.substring(0, 50)}${firstMessage.length > 50 ? '...' : ''}
                </div>
            </div>
        `;
    }).join('');
}

// Open create form
function openCreateForm() {
    selectedNPC = null;
    capturedCoords = null;
    
    document.getElementById('welcomeMessage').style.display = 'none';
    document.getElementById('npcForm').style.display = 'block';
    document.getElementById('formTitle').textContent = 'Neuer NPC';
    document.getElementById('deleteBtn').style.display = 'none';
    
    // Reset form
    document.getElementById('npcId').value = '';
    document.getElementById('pedModel').value = 'a_m_y_hipster_01';
    document.getElementById('scenario').value = 'WORLD_HUMAN_CLIPBOARD';
    document.getElementById('enablePatrol').checked = false;
    document.getElementById('patrolRadius').value = '10';
    document.getElementById('messages').value = '';
    document.getElementById('patrolRadiusGroup').style.display = 'none';
    
    updateCoordsDisplay();
}

// Edit NPC
function editNPC(index) {
    selectedNPC = index;
    const npc = currentNPCs[index];
    
    document.getElementById('welcomeMessage').style.display = 'none';
    document.getElementById('npcForm').style.display = 'block';
    document.getElementById('formTitle').textContent = `NPC #${index + 1} bearbeiten`;
    document.getElementById('deleteBtn').style.display = 'block';
    
    // Fill form with NPC data
    document.getElementById('npcId').value = index;
    document.getElementById('pedModel').value = npc.pedModel || 'a_m_y_hipster_01';
    document.getElementById('scenario').value = npc.scenario || '';
    document.getElementById('enablePatrol').checked = npc.enablePatrol || false;
    document.getElementById('patrolRadius').value = npc.patrolRadius || 10;
    document.getElementById('messages').value = (npc.messages || []).join('\n');
    
    capturedCoords = npc.position ? {
        x: npc.position.x,
        y: npc.position.y,
        z: npc.position.z,
        heading: npc.heading || 0
    } : null;
    
    updateCoordsDisplay();
    togglePatrolRadius();
    renderNPCList();
}

// Spawn NPC
function spawnNPC(index) {
    fetch(`https://${GetParentResourceName()}/spawnNPC`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ index: index })
    });
}

// Capture coordinates
function captureCoords() {
    fetch(`https://${GetParentResourceName()}/captureCoords`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// Update coords display
function updateCoordsDisplay() {
    const coordText = document.getElementById('coordText');
    if (capturedCoords) {
        coordText.textContent = `X: ${capturedCoords.x.toFixed(2)}, Y: ${capturedCoords.y.toFixed(2)}, Z: ${capturedCoords.z.toFixed(2)}, H: ${capturedCoords.heading.toFixed(2)}`;
        coordText.style.color = '#10b981';
    } else {
        coordText.textContent = 'Nicht gesetzt';
        coordText.style.color = '#ef4444';
    }
}

// Toggle patrol radius field
document.getElementById('enablePatrol').addEventListener('change', togglePatrolRadius);

function togglePatrolRadius() {
    const enabled = document.getElementById('enablePatrol').checked;
    document.getElementById('patrolRadiusGroup').style.display = enabled ? 'block' : 'none';
}

// Save NPC
function saveNPC() {
    if (!capturedCoords) {
        alert('Bitte setze zuerst die Position!');
        return;
    }
    
    const messages = document.getElementById('messages').value
        .split('\n')
        .map(m => m.trim())
        .filter(m => m.length > 0);
    
    if (messages.length === 0) {
        alert('Bitte füge mindestens eine Nachricht hinzu!');
        return;
    }
    
    const npcData = {
        position: {
            x: capturedCoords.x,
            y: capturedCoords.y,
            z: capturedCoords.z
        },
        heading: capturedCoords.heading,
        pedModel: document.getElementById('pedModel').value,
        patrolRadius: parseFloat(document.getElementById('patrolRadius').value),
        enablePatrol: document.getElementById('enablePatrol').checked,
        scenario: document.getElementById('scenario').value,
        messages: messages
    };
    
    const isEdit = selectedNPC !== null;
    
    fetch(`https://${GetParentResourceName()}/saveNPC`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            npc: npcData,
            index: isEdit ? selectedNPC : -1
        })
    }).then(() => {
        loadNPCs();
        cancelForm();
    });
}

// Delete NPC
function deleteNPC() {
    if (!confirm('Möchtest du diesen NPC wirklich löschen?')) {
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/deleteNPC`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ index: selectedNPC })
    }).then(() => {
        loadNPCs();
        cancelForm();
    });
}

// Cancel form
function cancelForm() {
    document.getElementById('welcomeMessage').style.display = 'block';
    document.getElementById('npcForm').style.display = 'none';
    selectedNPC = null;
    capturedCoords = null;
    renderNPCList();
}

// Get parent resource name
function GetParentResourceName() {
    let resource = window.location.hostname;
    if (resource === '') {
        resource = 'nui-frame-' + (window.name || 'unknown');
        resource = resource.replace(/nui-frame-/, '');
    }
    return resource;
}
