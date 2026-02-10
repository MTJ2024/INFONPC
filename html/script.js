let currentNPCs = [];
let selectedNPCIndex = null;
let isEditMode = false;

// Initialize
window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.action === 'open') {
        openUI(data.npcs || []);
    } else if (data.action === 'close') {
        closeUI();
    } else if (data.action === 'updateNPCs') {
        currentNPCs = data.npcs || [];
        renderNPCList();
    } else if (data.action === 'setPosition') {
        if (data.coords) {
            document.getElementById('posX').value = data.coords.x.toFixed(2);
            document.getElementById('posY').value = data.coords.y.toFixed(2);
            document.getElementById('posZ').value = data.coords.z.toFixed(2);
        }
    } else if (data.action === 'setHeading') {
        if (data.heading !== undefined) {
            document.getElementById('heading').value = data.heading.toFixed(2);
        }
    }
});

// ESC to close
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closeUI();
    }
});

function openUI(npcs) {
    currentNPCs = npcs;
    document.getElementById('npc-manager').classList.remove('hidden');
    renderNPCList();
    showWelcome();
}

function closeUI() {
    document.getElementById('npc-manager').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function renderNPCList() {
    const listContainer = document.getElementById('npcList');
    listContainer.innerHTML = '';
    
    currentNPCs.forEach((npc, index) => {
        const item = document.createElement('div');
        item.className = 'npc-item' + (index === selectedNPCIndex ? ' active' : '');
        item.onclick = () => editNPC(index);
        
        const header = document.createElement('div');
        header.className = 'npc-item-header';
        header.textContent = `NPC #${index + 1}`;
        
        const info = document.createElement('div');
        info.className = 'npc-item-info';
        info.textContent = `${npc.pedModel} | ${npc.messages.length} Nachrichten`;
        
        item.appendChild(header);
        item.appendChild(info);
        listContainer.appendChild(item);
    });
}

function createNewNPC() {
    selectedNPCIndex = null;
    isEditMode = false;
    
    document.getElementById('editorTitle').textContent = 'Neuer NPC';
    document.getElementById('deleteBtn').style.display = 'none';
    document.getElementById('editorSection').style.display = 'block';
    document.getElementById('welcomeSection').style.display = 'none';
    
    // Clear form
    document.getElementById('pedModel').value = 'a_m_y_hipster_01';
    document.getElementById('posX').value = '';
    document.getElementById('posY').value = '';
    document.getElementById('posZ').value = '';
    document.getElementById('heading').value = '0';
    document.getElementById('scenario').value = 'WORLD_HUMAN_CLIPBOARD';
    document.getElementById('enablePatrol').checked = false;
    document.getElementById('patrolRadius').value = '10.0';
    document.getElementById('messages').value = '';
}

function editNPC(index) {
    selectedNPCIndex = index;
    isEditMode = true;
    
    const npc = currentNPCs[index];
    
    document.getElementById('editorTitle').textContent = `NPC #${index + 1} bearbeiten`;
    document.getElementById('deleteBtn').style.display = 'inline-block';
    document.getElementById('editorSection').style.display = 'block';
    document.getElementById('welcomeSection').style.display = 'none';
    
    // Fill form
    document.getElementById('pedModel').value = npc.pedModel || '';
    document.getElementById('posX').value = npc.position.x || '';
    document.getElementById('posY').value = npc.position.y || '';
    document.getElementById('posZ').value = npc.position.z || '';
    document.getElementById('heading').value = npc.heading || 0;
    document.getElementById('scenario').value = npc.scenario || '';
    document.getElementById('enablePatrol').checked = npc.enablePatrol || false;
    document.getElementById('patrolRadius').value = npc.patrolRadius || 10.0;
    document.getElementById('messages').value = (npc.messages || []).join('\n');
    
    renderNPCList();
}

function saveNPC() {
    const pedModel = document.getElementById('pedModel').value.trim();
    const posX = parseFloat(document.getElementById('posX').value);
    const posY = parseFloat(document.getElementById('posY').value);
    const posZ = parseFloat(document.getElementById('posZ').value);
    const heading = parseFloat(document.getElementById('heading').value);
    const scenario = document.getElementById('scenario').value.trim();
    const enablePatrol = document.getElementById('enablePatrol').checked;
    const patrolRadius = parseFloat(document.getElementById('patrolRadius').value);
    const messagesText = document.getElementById('messages').value;
    
    // Validation
    if (!pedModel) {
        alert('Bitte gib ein Ped Model ein!');
        return;
    }
    
    if (isNaN(posX) || isNaN(posY) || isNaN(posZ)) {
        alert('Bitte gib gültige Koordinaten ein!');
        return;
    }
    
    if (isNaN(heading)) {
        alert('Bitte gib ein gültiges Heading ein!');
        return;
    }
    
    const messages = messagesText.split('\n').filter(m => m.trim() !== '');
    if (messages.length === 0) {
        alert('Bitte gib mindestens eine Nachricht ein!');
        return;
    }
    
    const npcData = {
        pedModel: pedModel,
        position: { x: posX, y: posY, z: posZ },
        heading: heading,
        scenario: scenario || 'WORLD_HUMAN_CLIPBOARD',
        enablePatrol: enablePatrol,
        patrolRadius: patrolRadius || 10.0,
        messages: messages
    };
    
    fetch(`https://${GetParentResourceName()}/saveNPC`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            index: isEditMode ? selectedNPCIndex : null,
            npc: npcData
        })
    });
}

function deleteNPC() {
    if (selectedNPCIndex === null) return;
    
    if (confirm(`Möchtest du NPC #${selectedNPCIndex + 1} wirklich löschen?`)) {
        fetch(`https://${GetParentResourceName()}/deleteNPC`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ index: selectedNPCIndex })
        });
        
        showWelcome();
    }
}

function cancelEdit() {
    showWelcome();
}

function showWelcome() {
    selectedNPCIndex = null;
    document.getElementById('editorSection').style.display = 'none';
    document.getElementById('welcomeSection').style.display = 'block';
    renderNPCList();
}

function getCurrentPosition() {
    fetch(`https://${GetParentResourceName()}/getCurrentPosition`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function getCurrentHeading() {
    fetch(`https://${GetParentResourceName()}/getCurrentHeading`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function GetParentResourceName() {
    return 'INFONPC';
}
