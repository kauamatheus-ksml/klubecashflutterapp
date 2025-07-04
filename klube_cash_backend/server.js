require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const cors = require('cors');
const crypto = require('crypto');
const nodemailer = require('nodemailer');

const app = express();
const port = process.env.PORT || 3001; 

app.use(cors());
app.use(express.json());

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
};

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: true,
  auth: {
    user: process.env.SMTP_USERNAME,
    pass: process.env.SMTP_PASSWORD,
  },
  tls: {
    rejectUnauthorized: false
  }
});

async function sendEmail(toEmail, toName, subject, htmlContent) {
  const mailOptions = {
    from: `"${process.env.SMTP_FROM_NAME}" <${process.env.SMTP_FROM_EMAIL}>`,
    to: `${toName} <${toEmail}>`,
    subject: subject,
    html: htmlContent,
    text: htmlContent.replace(/<[^>]*>?/gm, ''),
  };

  try {
    let info = await transporter.sendMail(mailOptions);
    console.log('E-mail enviado: %s', info.messageId);
    return true;
  } catch (error) {
    console.error('Erro ao enviar e-mail:', error);
    throw new Error('Falha ao enviar e-mail. Por favor, tente novamente.');
  }
}

const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (token == null) {
    return res.sendStatus(401); 
  }

  const simulatedUserId = 9; 
  const simulatedAuthToken = 'seu_super_token_secreto_aqui_para_simulacao'; 

  if (token === simulatedAuthToken) {
    req.userId = simulatedUserId; 
    next(); 
  } else {
    return res.sendStatus(403); 
  }
};

app.post('/api/login', async (req, res) => {
  const { email, senha } = req.body;

  if (!email || !senha) {
    return res.status(400).json({ message: 'Email e senha são obrigatórios.' });
  }

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [rows] = await connection.execute(
      'SELECT id, nome, email, senha_hash, tipo FROM usuarios WHERE email = ?',
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({ message: 'Email ou senha incorretos.' });
    }

    const user = rows[0];
    const isPasswordValid = await bcrypt.compare(senha, user.senha_hash);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Email ou senha incorretos.' });
    }

    delete user.senha_hash;

    const authTokenForFlutter = 'seu_super_token_secreto_aqui_para_simulacao'; 

    res.status(200).json({ 
      message: 'Login bem-sucedido!', 
      user: user,
      token: authTokenForFlutter 
    });

  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end(); 
  }
});

app.post('/api/register', async (req, res) => {
  const { nome, email, telefone, senha, tipo } = req.body;

  if (!nome || !email || !telefone || !senha) {
    return res.status(400).json({ message: 'Todos os campos obrigatórios devem ser preenchidos.' });
  }

  if (!/\S+@\S+\.\S+/.test(email)) {
    return res.status(400).json({ message: 'Formato de e-mail inválido.' });
  }

  if (senha.length < 8) {
      return res.status(400).json({ message: 'A senha deve ter no mínimo 8 caracteres.' });
  }
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/.test(senha)) {
      return res.status(400).json({ message: 'A senha deve conter pelo menos uma letra maiúscula, uma minúscula e um número.' });
  }

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [existingUsers] = await connection.execute(
      'SELECT id FROM usuarios WHERE email = ?',
      [email]
    );

    if (existingUsers.length > 0) {
      return res.status(409).json({ message: 'Este e-mail já está cadastrado.' });
    }

    const hashedPassword = await bcrypt.hash(senha, 10);

    const [result] = await connection.execute(
      'INSERT INTO usuarios (nome, email, telefone, senha_hash, data_criacao, status, tipo) VALUES (?, ?, ?, ?, NOW(), ?, ?)',
      [nome, email, telefone, hashedPassword, 'ativo', tipo || 'cliente']
    );

    if (result.affectedRows === 1) {
      res.status(201).json({ message: 'Usuário registrado com sucesso!' });
    } else {
      res.status(500).json({ message: 'Erro ao registrar usuário.' });
    }

  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end();
  }
});

app.post('/api/request-password-reset', async (req, res) => {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: 'Email é obrigatório.' });
  }

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [users] = await connection.execute(
      'SELECT id, nome FROM usuarios WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(200).json({ message: 'Se o e-mail estiver cadastrado, as instruções foram enviadas.' });
    }

    const user = users[0];
    const userId = user.id;
    const userName = user.nome;

    const token = crypto.randomBytes(32).toString('hex');
    const tokenExpirationSeconds = 7200; 
    const expiresAt = new Date(Date.now() + tokenExpirationSeconds * 1000);

    await connection.execute(
      'DELETE FROM recuperacao_senha WHERE usuario_id = ?',
      [userId]
    );

    await connection.execute(
      'INSERT INTO recuperacao_senha (usuario_id, token, data_expiracao, usado) VALUES (?, ?, ?, ?)',
      [userId, token, expiresAt, 0]
    );

    const siteUrl = 'https://klubecash.com'; 
    const resetLink = `${siteUrl}/views/auth/recover-password.php?token=${token}`; 

    const emailSubject = 'Recuperação de Senha - Klube Cash';
    const emailHtml = `
      <h2 style="color: #333333;">Olá, ${userName}!</h2>
      <p>Recebemos uma solicitação para redefinir a senha da sua conta no Klube Cash.</p>
      <p>Para criar uma nova senha, por favor, clique no botão abaixo. Lembre-se que este link é de uso único e <strong>expirará em 2 horas</strong> por motivos de segurança.</p>
      <p style="text-align: center; margin: 30px 0;">
          <a href="${resetLink}" style="display: inline-block; background-color: #FF7A00; color: white !important; padding: 14px 28px; text-decoration: none; border-radius: 30px; font-weight: 600; font-size: 15px; text-transform: uppercase; letter-spacing: 0.5px;">Redefinir Minha Senha</a>
      </p>
      <p>Se você não solicitou esta alteração, pode ignorar este email com segurança. Nenhuma modificação será feita em sua conta.</p>
      <p>Caso tenha alguma dúvida ou identifique qualquer atividade suspeita, não hesite em entrar em contato conosco.</p>
      <p>Atenciosamente,<br><strong>Equipe Klube Cash</strong></p>
    `;

    await sendEmail(email, userName, emailSubject, emailHtml);
    
    res.status(200).json({ message: 'Se o e-mail estiver cadastrado, as instruções foram enviadas.' });

  } catch (error) {
    console.error('Erro ao solicitar recuperação de senha:', error);
    res.status(500).json({ message: error.message || 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end();
  }
});

app.post('/api/reset-password', async (req, res) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword) {
    return res.status(400).json({ message: 'Token e nova senha são obrigatórios.' });
  }

  if (newPassword.length < 8) {
      return res.status(400).json({ message: 'A senha deve ter no mínimo 8 caracteres.' });
  }
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/.test(newPassword)) {
      return res.status(400).json({ message: 'A senha deve conter pelo menos uma letra maiúscula, uma minúscula e um número.' });
  }

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [recoveryTokens] = await connection.execute(
      'SELECT usuario_id, data_expiracao, usado FROM recuperacao_senha WHERE token = ?',
      [token]
    );

    if (recoveryTokens.length === 0) {
      return res.status(400).json({ message: 'Token inválido ou não encontrado.' });
    }

    const recovery = recoveryTokens[0];

    if (recovery.usado) {
      return res.status(400).json({ message: 'Token já utilizado. Por favor, solicite uma nova recuperação.' });
    }

    const expirationDate = new Date(recovery.data_expiracao);
    if (expirationDate < new Date()) {
      return res.status(400).json({ message: 'Token expirado. Por favor, solicite uma nova recuperação.' });
    }

    const userId = recovery.usuario_id;

    const hashedPassword = await bcrypt.hash(newPassword, 10);

    await connection.execute(
      'UPDATE usuarios SET senha_hash = ? WHERE id = ?',
      [hashedPassword, userId]
    );

    await connection.execute(
      'UPDATE recuperacao_senha SET usado = 1 WHERE token = ?',
      [token]
    );

    res.status(200).json({ message: 'Senha redefinida com sucesso!' });

  } catch (error) {
    console.error('Erro ao redefinir senha:', error);
    res.status(500).json({ message: error.message || 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end();
  }
});

app.get('/api/profile', authenticateToken, async (req, res) => {
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [rows] = await connection.execute(
      `SELECT
         u.nome, u.cpf, u.email, u.telefone, uc.email_alternativo,
         ue.cep, ue.logradouro, ue.numero, ue.complemento, ue.bairro, ue.cidade, ue.estado
       FROM usuarios u
       LEFT JOIN usuarios_contato uc ON u.id = uc.usuario_id
       LEFT JOIN usuarios_endereco ue ON u.id = ue.usuario_id AND ue.principal = 1
       WHERE u.id = ?`,
      [req.userId]
    );

    if (rows.length > 0) {
      const userData = rows[0];
      const profileData = {
        nome: userData.nome,
        cpf: userData.cpf,
        email: userData.email,
        telefone: userData.telefone,
        email_alternativo: userData.email_alternativo,
        cep: userData.cep,
        logradouro: userData.logradouro,
        numero: userData.numero,
        complemento: userData.complemento,
        bairro: userData.bairro,
        cidade: userData.cidade,
        estado: userData.estado,
      };
      res.json({ user: profileData });
    } else {
      res.status(404).json({ message: 'Usuário não encontrado.' });
    }
  } catch (error) {
    console.error('Erro ao buscar perfil:', error);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end();
  }
});

app.put('/api/profile/update', authenticateToken, async (req, res) => {
  const { nome, cpf, email, telefone, email_alternativo, cep, logradouro, numero, complemento, bairro, cidade, estado } = req.body;
  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    await connection.beginTransaction();

    await connection.execute(
      'UPDATE usuarios SET nome = ?, telefone = ? WHERE id = ?',
      [nome, telefone, req.userId]
    );

    const [existingContact] = await connection.execute(
      'SELECT id FROM usuarios_contato WHERE usuario_id = ?',
      [req.userId]
    );

    if (existingContact.length > 0) {
      await connection.execute(
        'UPDATE usuarios_contato SET email_alternativo = ? WHERE usuario_id = ?',
        [email_alternativo, req.userId]
      );
    } else {
      await connection.execute(
        'INSERT INTO usuarios_contato (usuario_id, telefone, email_alternativo) VALUES (?, ?, ?)',
        [req.userId, telefone, email_alternativo]
      );
    }

    const [existingAddress] = await connection.execute(
      'SELECT id FROM usuarios_endereco WHERE usuario_id = ? AND principal = 1',
      [req.userId]
    );

    if (existingAddress.length > 0) {
      await connection.execute(
        'UPDATE usuarios_endereco SET cep = ?, logradouro = ?, numero = ?, complemento = ?, bairro = ?, cidade = ?, estado = ? WHERE usuario_id = ? AND principal = 1',
        [cep, logradouro, numero, complemento, bairro, cidade, estado, req.userId]
      );
    } else {
      await connection.execute(
        'INSERT INTO usuarios_endereco (usuario_id, cep, logradouro, numero, complemento, bairro, cidade, estado, principal) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)',
        [req.userId, cep, logradouro, numero, complemento, bairro, cidade, estado]
      );
    }

    await connection.commit(); 

    res.json({ message: 'Perfil atualizado com sucesso!' });

  } catch (error) {
    await connection?.rollback(); 
    console.error('Erro ao atualizar perfil:', error);
    res.status(500).json({ message: 'Erro interno do servidor ao atualizar perfil.' });
  } finally {
    if (connection) connection.end();
  }
});

app.post('/api/change-password', authenticateToken, async (req, res) => {
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Senha atual e nova senha são obrigatórias.' });
  }

  if (newPassword.length < 8) {
    return res.status(400).json({ message: 'A nova senha deve ter no mínimo 8 caracteres.' });
  }
  if (!/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).*$/.test(newPassword)) {
    return res.status(400).json({ message: 'A nova senha deve conter pelo menos uma letra maiúscula, uma minúscula e um número.' });
  }

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);
    const [rows] = await connection.execute(
      'SELECT senha_hash FROM usuarios WHERE id = ?',
      [req.userId]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'Usuário não encontrado.' });
    }

    const user = rows[0]; 
    const isPasswordValid = await bcrypt.compare(currentPassword, user.senha_hash);

    if (isPasswordValid) {
      const hashedPassword = await bcrypt.hash(newPassword, 10);
      await connection.execute(
        'UPDATE usuarios SET senha_hash = ? WHERE id = ?',
        [hashedPassword, req.userId]
      );
      res.json({ message: 'Senha alterada com sucesso!' });
    } else {
      res.status(401).json({ message: 'Senha atual incorreta.' });
    }
  } catch (error) {
    console.error('Erro ao alterar senha:', error);
    res.status(500).json({ message: 'Erro interno do servidor.' });
  } finally {
    if (connection) connection.end();
  }
});

/**
 * Rota GET para buscar o histórico de transações de cashback do usuário autenticado.
 * Requer o middleware `authenticateToken` e suporta paginação via `limit` e `offset`.
 */
app.get('/api/transactions', authenticateToken, async (req, res) => {
  const userId = req.userId;
  const limit = parseInt(req.query.limit) || 5;
  const offset = parseInt(req.query.offset) || 0;

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [transactions] = await connection.execute(
      `SELECT
         tc.id,
         COALESCE(tc.valor_total, 0) AS valor_total,       -- Usar COALESCE para garantir não nulo
         COALESCE(tc.valor_cashback, 0) AS valor_cashback, -- Usar COALESCE para garantir não nulo
         tc.data_transacao,
         tc.status,
         l.nome_fantasia AS loja_nome,
         COALESCE(tsu.valor_usado, 0) AS valor_usado,
         COALESCE(tc.valor_cliente, 0) AS valor_cashback_cliente -- O VALOR CORRETO PARA O CLIENTE (5%)
       FROM transacoes_cashback tc
       JOIN lojas l ON tc.loja_id = l.id
       LEFT JOIN transacoes_saldo_usado tsu ON tc.id = tsu.transacao_id
       WHERE tc.usuario_id = ?
       ORDER BY tc.data_transacao DESC
       LIMIT ? OFFSET ?`,
      [userId, limit, offset]
    );

    const formattedTransactions = transactions.map(t => ({
      ...t,
      valor_total: parseFloat(t.valor_total),
      valor_cashback: parseFloat(t.valor_cashback_cliente),
      valor_usado: parseFloat(t.valor_usado),
    }));

    res.json({ transactions: formattedTransactions });

  } catch (error) {
    console.error('Erro ao buscar histórico de transações:', error);
    res.status(500).json({ message: 'Erro interno do servidor ao buscar histórico de transações.' });
  } finally {
    if (connection) connection.end();
  }
});


// Rota GET para buscar o saldo do usuário autenticado.
// Requer o middleware `authenticateToken`.
app.get('/api/user-balance', authenticateToken, async (req, res) => {
  const userId = req.userId;

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [balanceRows] = await connection.execute(
      `SELECT
         COALESCE(SUM(saldo_disponivel), 0) AS saldo_disponivel,
         COALESCE(SUM(total_creditado), 0) AS total_creditado,
         COALESCE(SUM(total_usado), 0) AS total_usado,
          COALESCE(SUM(CASE WHEN tc.status = 'pendente' THEN tc.valor_cliente ELSE 0 END), 0) AS saldo_pendente
       FROM cashback_saldos cs
        LEFT JOIN transacoes_cashback tc ON cs.usuario_id = tc.usuario_id AND cs.loja_id = tc.loja_id -- Join para pegar transações pendentes por loja
       WHERE cs.usuario_id = ?`,
      [userId]
    );

    const balanceData = {
      saldo_disponivel: parseFloat(balanceRows[0]?.saldo_disponivel || 0),
      total_creditado: parseFloat(balanceRows[0]?.total_creditado || 0),
      total_usado: parseFloat(balanceRows[0]?.total_usado || 0),
      saldo_pendente: parseFloat(balanceRows[0]?.saldo_pendente || 0), // NOVO: Saldo Pendente
    };

    res.json({ balance: balanceData });

  } catch (error) {
    console.error('Erro ao buscar saldo do usuário:', error);
    res.status(500).json({ message: 'Erro interno do servidor ao buscar saldo.' });
  } finally {
    if (connection) connection.end();
  }
});


// Rota GET para buscar lojas populares ou parceiras.
// Requer o middleware `authenticateToken`.
// Suporta um `limit` para o número de lojas a serem retornadas.
app.get('/api/popular-stores', authenticateToken, async (req, res) => {
  const limit = parseInt(req.query.limit) || 5; // Padrão 5 lojas

  let connection;
  try {
    connection = await mysql.createConnection(dbConfig);

    const [stores] = await connection.execute(
      `SELECT
         id,
         nome_fantasia,
         porcentagem_cashback,
         logo
       FROM lojas
       WHERE status = 'aprovado'
       ORDER BY data_cadastro DESC
       LIMIT ?`,
      [limit]
    );

    const formattedStores = stores.map(s => ({
      ...s,
      porcentagem_cashback: parseFloat(s.porcentagem_cashback),
      // logo: s.logo ? `https://klubecash.com/assets/images/logos/${s.logo}` : null,
    }));

    res.json({ stores: formattedStores });

  } catch (error) {
    console.error('Erro ao buscar lojas populares:', error);
    res.status(500).json({ message: 'Erro interno do servidor ao buscar lojas.' });
  } finally {
    if (connection) connection.end();
  }
});

// Inicia o servidor Express na porta definida (3001 ou a do .env).
app.listen(port, () => {
  console.log(`Servidor rodando em http://localhost:${port}`);
});